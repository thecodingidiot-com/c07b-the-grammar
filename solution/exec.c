#include <sys/wait.h>
#include <unistd.h>
#include <stdio.h>
#include "shell.h"

int exec_simple(t_shell *sh, char **argv)
{
    pid_t   pid;
    int     status;

    pid = fork();
    if (pid < 0) {
        tci_printf("fork: failed\n");
        return (1);
    }
    if (pid == 0) {
        execvp(argv[0], argv);
        fprintf(stderr, "%s: command not found\n", argv[0]);
        _exit(127);
    }
    waitpid(pid, &status, 0);
    (void)sh;
    if (WIFEXITED(status))
        return (WEXITSTATUS(status));
    if (WIFSIGNALED(status))
        return (128 + WTERMSIG(status));
    return (1);
}

/* Checkpoint B (c07b): only NODE_CMD is real. NODE_PIPE gets wired up at
 * c07c; NODE_AND/NODE_OR/NODE_SUBSHELL at c07d. Reaching any of those here
 * means the parser accepted a grammar this checkpoint's executor doesn't
 * implement yet -- report it cleanly instead of doing nothing silently. */
int exec_node(t_shell *sh, t_node *node)
{
    if (node->type == NODE_CMD) {
        if (is_builtin(node->argv[0]))
            return (run_builtin(sh, node->argv));
        return (exec_simple(sh, node->argv));
    }
    fprintf(stderr, "c07shell: this checkpoint does not execute that yet\n");
    return (1);
}
