###
### Comprehensive SQL Syntax Validator for Liquibase
###
### Validates individual changesets within formatted SQL files
###
import os
import sys
import re
import liquibase_utilities

###
### Retrieve handlers
###
liquibase_logger = liquibase_utilities.get_logger()
liquibase_status = liquibase_utilities.get_status()

###
### Get the current changeset being processed
###
changeset = liquibase_utilities.get_changeset()
filepath = changeset.getChangeLog().getPhysicalFilePath()

###
### Ignore if not sql file
###
ext = os.path.splitext(filepath)[-1].lower()
if ext != ".sql":
    liquibase_logger.info(f"{ext} file extension skipped.")
    liquibase_status.fired = False
    sys.exit(0)

###
### Read entire file
###
try:
    with open(filepath, 'r', encoding='utf-8') as file:
        all_lines = file.readlines()
except Exception as e:
    liquibase_status.fired = True
    liquibase_status.message = f"Failed to read file: {str(e)}"
    sys.exit(1)

###
### Parse file to find changeset boundaries
###
def parse_changesets(lines):
    """Parse SQL file and identify changeset boundaries"""
    changesets = []
    current_changeset = None
    current_lines = []
    start_line = 1
    
    for i, line in enumerate(lines, 1):
        if re.match(r'^\s*--\s*changeset\s+', line, re.IGNORECASE):
            if current_changeset:
                changesets.append({
                    'id': current_changeset,
                    'start_line': start_line,
                    'end_line': i - 1,
                    'lines': current_lines
                })
            
            match = re.search(r'changeset\s+([^:\s]+):([^\s]+)', line, re.IGNORECASE)
            if match:
                current_changeset = f"{match.group(1)}:{match.group(2)}"
            else:
                current_changeset = f"unknown:{i}"
            
            start_line = i
            current_lines = [line]
        elif current_changeset:
            current_lines.append(line)
    
    if current_changeset:
        changesets.append({
            'id': current_changeset,
            'start_line': start_line,
            'end_line': len(lines),
            'lines': current_lines
        })
    
    return changesets

###
### Get current changeset ID
###
try:
    current_changeset_id = f"{changeset.getAuthor()}:{changeset.getId()}"
except:
    current_changeset_id = None

###
### Parse and find changeset
###
parsed_changesets = parse_changesets(all_lines)
changeset_to_validate = None

for cs in parsed_changesets:
    if current_changeset_id and cs['id'] == current_changeset_id:
        changeset_to_validate = cs
        break

if not changeset_to_validate:
    liquibase_logger.info(f"Changeset {current_changeset_id} not found")
    liquibase_status.fired = False
    sys.exit(0)

###
### Extract changeset data
###
lines = changeset_to_validate['lines']
start_line_number = changeset_to_validate['start_line']

###
### Helper functions
###
def is_comment_line(line):
    stripped = line.strip()
    return stripped.startswith('--') or stripped.startswith('/*') or stripped.startswith('*')

def is_rollback_line(line):
    stripped = line.strip()
    return stripped.startswith('--rollback')

###
### Store errors: (line_offset, error_message, severity)
###
errors = []

###
### Join content for multi-line pattern matching
###
content_str = ''.join(lines)

###
### Check 1: Verify "formatted sql" header (only first changeset)
###
if start_line_number == 1:
    found_header = False
    for line in lines[:5]:
        if "--liquibase formatted sql" in line.lower():
            found_header = True
            break
    if not found_header:
        errors.append((1, "Missing '--liquibase formatted sql' header", "CRITICAL"))

###
### Check 2: CREAE instead of CREATE (common typo)
###
for i, line in enumerate(lines, 1):
    if is_comment_line(line) or is_rollback_line(line):
        continue
    # Check for CREAE (missing T)
    if re.search(r'\bCREAE\b', line, re.IGNORECASE):
        errors.append((i, "'CREAE' should be 'CREATE'", "CRITICAL"))
    # Check for CREAT followed by space and TABLE/PROCEDURE etc
    if re.search(r'\bCREAT\s+TABLE\b', line, re.IGNORECASE):
        errors.append((i, "'CREAT TABLE' should be 'CREATE TABLE'", "CRITICAL"))
    if re.search(r'\bCREAT\s+PROCEDURE\b', line, re.IGNORECASE):
        errors.append((i, "'CREAT PROCEDURE' should be 'CREATE PROCEDURE'", "CRITICAL"))
    if re.search(r'\bCREAT\s+FUNCTION\b', line, re.IGNORECASE):
        errors.append((i, "'CREAT FUNCTION' should be 'CREATE FUNCTION'", "CRITICAL"))
    if re.search(r'\bCREAT\s+INDEX\b', line, re.IGNORECASE):
        errors.append((i, "'CREAT INDEX' should be 'CREATE INDEX'", "CRITICAL"))

###
### Check 3: ALTER typos
###
for i, line in enumerate(lines, 1):
    if is_comment_line(line) or is_rollback_line(line):
        continue
    # ALTR
    if re.search(r'\bALTR\b', line, re.IGNORECASE):
        errors.append((i, "'ALTR' should be 'ALTER'", "ERROR"))
    # ALTE
    if re.search(r'\bALTE\s+TABLE\b', line, re.IGNORECASE):
        errors.append((i, "'ALTE TABLE' should be 'ALTER TABLE'", "ERROR"))

###
### Check 4: Other common typos
###
typo_patterns = [
    (r'\bTABEL\b', "'TABEL' should be 'TABLE'", "ERROR"),
    (r'\bPROCEDUR\b', "'PROCEDUR' should be 'PROCEDURE'", "ERROR"),
    (r'\bFUNCTIO\b', "'FUNCTIO' should be 'FUNCTION'", "ERROR"),
    (r'\bINSERT\s+INT\b', "'INSERT INT' should be 'INSERT INTO'", "ERROR"),
    (r'\bINSRT\b', "'INSRT' should be 'INSERT'", "ERROR"),
    (r'\bSELCT\b', "'SELCT' should be 'SELECT'", "ERROR"),
    (r'\bDELTE\b', "'DELTE' should be 'DELETE'", "ERROR"),
    (r'\bUPDATE\b.*\bSET\b.*\bWHERE\b.*\bADN\b', "'ADN' should be 'AND'", "ERROR"),
    (r'\bAD\s+COLUMN\b', "'AD COLUMN' should be 'ADD COLUMN'", "ERROR"),
    (r'\bAD\s+CONSTRAINT\b', "'AD CONSTRAINT' should be 'ADD CONSTRAINT'", "ERROR"),
]

for pattern, msg, severity in typo_patterns:
    for i, line in enumerate(lines, 1):
        if is_comment_line(line) or is_rollback_line(line):
            continue
        if re.search(pattern, line, re.IGNORECASE):
            errors.append((i, msg, severity))

###
### Check 5: Unmatched parentheses
###
# Remove comments and rollback lines for this check
non_comment_lines = []
for i, line in enumerate(lines, 1):
    if not is_comment_line(line) and not is_rollback_line(line):
        # Remove inline comments
        cleaned = re.sub(r'--.*$', '', line)
        non_comment_lines.append((i, cleaned))

# Count parentheses
total_open = sum(line[1].count('(') for line in non_comment_lines)
total_close = sum(line[1].count(')') for line in non_comment_lines)

if total_open != total_close:
    # Find where imbalance occurs
    cumulative_open = 0
    cumulative_close = 0
    problem_line = None
    
    for i, cleaned_line in non_comment_lines:
        cumulative_open += cleaned_line.count('(')
        cumulative_close += cleaned_line.count(')')
        if cumulative_close > cumulative_open and not problem_line:
            problem_line = i
            break
    
    if not problem_line:
        problem_line = non_comment_lines[-1][0] if non_comment_lines else len(lines)
    
    errors.append((problem_line, f"Unmatched parentheses: {total_open} '(' vs {total_close} ')'", "ERROR"))

###
### Check 6: Unmatched single quotes
###
for i, line in enumerate(lines, 1):
    if is_comment_line(line) or is_rollback_line(line):
        continue
    
    # Remove inline comments
    line_no_comment = re.sub(r'--.*$', '', line)
    quote_count = line_no_comment.count("'")
    
    if quote_count % 2 != 0:
        errors.append((i, "Unmatched single quotes", "ERROR"))

###
### Check 7: Missing commas in column definitions
###
for i, line in enumerate(lines, 1):
    if is_comment_line(line) or is_rollback_line(line):
        continue
    
    line_upper = line.upper()
    # Pattern: columnname datatype columnname datatype (missing comma)
    # Examples: NAME TEXT EMAIL TEXT or ID BIGINT NAME TEXT
    if re.search(r'\b[A-Z_][A-Z0-9_]*\s+(TEXT|VARCHAR|VARCHAR2|CHAR|INT|INTEGER|BIGINT|BIGSERIAL|NUMBER|DATE|TIMESTAMP|TIMESTAMPTZ|CLOB|BLOB)\s+[A-Z_][A-Z0-9_]*\s+(TEXT|VARCHAR|VARCHAR2|CHAR|INT|INTEGER|BIGINT|BIGSERIAL|NUMBER|DATE|TIMESTAMP|TIMESTAMPTZ|CLOB|BLOB)', line_upper):
        errors.append((i, "Missing comma between column definitions", "ERROR"))

###
### Check 8: Missing semicolons on statement ends
###
for i, line in enumerate(lines, 1):
    if is_comment_line(line) or is_rollback_line(line):
        continue
    
    line_stripped = line.strip()
    
    # Check if this line starts a major SQL statement
    if re.match(r'^(CREATE|ALTER|DROP|INSERT|UPDATE|DELETE|GRANT|REVOKE)\b', line_stripped, re.IGNORECASE):
        # Look ahead for semicolon
        found_semicolon = False
        for j in range(i - 1, min(i + 30, len(lines))):
            check_line = lines[j].strip()
            if is_rollback_line(lines[j]):
                continue
            if check_line.endswith(';'):
                found_semicolon = True
                break
            # Stop if we hit another statement
            if j > i and re.match(r'^(CREATE|ALTER|DROP|INSERT|UPDATE|DELETE|--|--changeset)', check_line, re.IGNORECASE):
                break
        
        if not found_semicolon:
            errors.append((i, "Statement missing terminating semicolon", "WARNING"))

###
### Check 9: PL/SQL structure issues
###
for i, line in enumerate(lines, 1):
    if is_comment_line(line) or is_rollback_line(line):
        continue
    
    # BEGIN without END
    if re.search(r'\bBEGIN\b', line, re.IGNORECASE):
        found_end = False
        for j in range(i, min(i + 100, len(lines))):
            if is_rollback_line(lines[j]):
                continue
            if re.search(r'\bEND\s*;', lines[j], re.IGNORECASE):
                found_end = True
                break
        if not found_end:
            errors.append((i, "BEGIN without matching END", "ERROR"))
    
    # IF without THEN
    if re.search(r'\bIF\b.*\bNOT\b.*\bEXISTS\b', line, re.IGNORECASE):
        # IF NOT EXISTS is valid, skip
        continue
    
    if re.search(r'\bIF\s+EXISTS\b', line, re.IGNORECASE):
        # IF EXISTS is valid, skip
        continue
        
    if re.search(r'\bIF\b', line, re.IGNORECASE):
        # Check for THEN on same line or next 2 lines
        has_then = re.search(r'\bTHEN\b', line, re.IGNORECASE)
        if not has_then and i < len(lines):
            has_then = re.search(r'\bTHEN\b', lines[i], re.IGNORECASE)
        if not has_then and i + 1 < len(lines):
            has_then = re.search(r'\bTHEN\b', lines[i + 1], re.IGNORECASE)
        if not has_then:
            errors.append((i, "IF without THEN", "ERROR"))

###
### Check 10: Double semicolons
###
for i, line in enumerate(lines, 1):
    if is_comment_line(line) or is_rollback_line(line):
        continue
    if ';;' in line:
        errors.append((i, "Double semicolon (;;)", "WARNING"))

###
### Check 11: Reserved words as identifiers (without quotes)
###
reserved_words = ['USER', 'LEVEL', 'SIZE', 'ORDER', 'GROUP', 'DATE', 'NUMBER']
for i, line in enumerate(lines, 1):
    if is_comment_line(line) or is_rollback_line(line):
        continue
    
    line_upper = line.upper()
    for word in reserved_words:
        # Check if reserved word is used as column name
        if re.search(rf'\b{word}\s+(TEXT|VARCHAR|INT|NOT\s+NULL)', line_upper):
            errors.append((i, f"Reserved word '{word}' as column name - use quotes", "WARNING"))

###
### Report results
###
if errors:
    # Sort by line number and severity
    severity_order = {'CRITICAL': 0, 'ERROR': 1, 'WARNING': 2}
    errors.sort(key=lambda x: (x[0], severity_order.get(x[2], 3)))
    
    liquibase_status.fired = True
    
    # Count by severity
    critical = sum(1 for e in errors if e[2] == 'CRITICAL')
    error_count = sum(1 for e in errors if e[2] == 'ERROR')
    warning = sum(1 for e in errors if e[2] == 'WARNING')
    
    # Compact report
    report = f"\nVALIDATION FAILED: {changeset_to_validate['id']}\n"
    report += f"Critical: {critical} | Errors: {error_count} | Warnings: {warning}\n"
    report += f"{'-'*55}\n"
    
    for line_offset, error_msg, severity in errors:
        # Calculate actual file line number
        actual_line = start_line_number + line_offset - 1
        sev = severity[:4]  # CRIT, ERRO, WARN
        report += f"[{sev}] Line {actual_line}: {error_msg}\n"
    
    report += f"{'-'*55}\n"
    
    liquibase_status.message = report
    liquibase_logger.info(report)
    sys.exit(1)

###
### Success
###
liquibase_logger.info(f"✓ Validated: {changeset_to_validate['id']}")
liquibase_status.fired = False
False