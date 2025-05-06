
# Running Supermarket Tests Locally

- Need to install google chrome / chromium browser to run a few tests. Steps below
  - Run the following commands in sequence
    - In MacOs
      - `brew tap homebrew/cask`
      - `brew install --cask chromium`
    - In Ubuntu/Debian
      - `sudo apt update`
      - `sudo apt install -y chromium-browser`
    - For other operating systems please check respective documentation.
- If you get error saying: too many open files
  - Your system has limit set on the number of files that can be open at the same time. You can check the limit and then increase it to a higher limit by the following
    - To check the current file descriptor limit:
    - `ulimit -n`
    - To increase the limit:
    - `ulimit -n <new_higher_limit>`
