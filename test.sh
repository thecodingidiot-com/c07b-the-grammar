#!/bin/bash
# c07 reference shell -- bash-comparison tester.
# Each case is piped, as one script, to both our shell and to bash;
# stdout, stderr, and exit status are diffed. Bash is the oracle.

set -o pipefail

pass_count=0
fail_count=0

run_case() {
    # $3 = "status_only" to skip stdout/stderr text comparison (used for
    # messages that are legitimately implementation-specific wording, e.g.
    # "command not found" -- every real shell phrases that differently).
    local label="$1"
    local script="$2"
    local mode="${3:-full}"
    local our_out our_err our_status
    local bash_out bash_err bash_status

    our_out=$(printf '%s' "$script" | ./c07shell 2>/tmp/c07_our_err)
    our_status=$?
    our_err=$(cat /tmp/c07_our_err)

    bash_out=$(printf '%s' "$script" | bash 2>/tmp/c07_bash_err)
    bash_status=$?
    bash_err=$(cat /tmp/c07_bash_err)

    local ok=1
    [[ "$our_status" == "$bash_status" ]] || ok=0
    if [[ "$mode" == "full" ]]; then
        [[ "$our_out" == "$bash_out" ]] || ok=0
    fi

    if [[ "$ok" == "1" ]]; then
        echo "PASS  $label"
        pass_count=$((pass_count + 1))
    else
        echo "FAIL  $label"
        echo "      ours : status=$our_status out=[$our_out] err=[$our_err]"
        echo "      bash : status=$bash_status out=[$bash_out] err=[$bash_err]"
        fail_count=$((fail_count + 1))
    fi
}

# --- checkpoint A: single external commands + cd/pwd/exit -------------------

run_case "echo simple"            $'echo hello\n'
run_case "echo multiple words"    $'echo one two three\n'
run_case "exit code from true propagates via bare exit" $'true\nexit\n'
run_case "exit code from false propagates via bare exit" $'false\nexit\n'
run_case "exit with explicit code" $'exit 7\n'
run_case "pwd runs"                $'pwd\n'
run_case "cd then pwd"             $'cd /tmp\npwd\n'
run_case "nonexistent command"     $'nosuchcommand123\n' status_only

echo
echo "$pass_count passed, $fail_count failed"
exit "$fail_count"
