
## Setup Supermarket Test Environment in Local

-   Need to install phantomjs to run a few tests. Steps below
    -   Run the following commands in sequence
        -   `brew tap homebrew/cask`
        -   `brew install --cask phantomjs`
-   If you get error saying: too many open files
    -   Your system has limit set on the number of files that can be open at the same time. You can check the limit and then increase it to a higher limit by the following
        -   To check the current file descriptor limit:
            -   `ulimit -n`
        -   To increase the limit:
            -   `ulimit -n <new_higher_limit>`