# mfa

`mfa` is a tool to generate time-based one time password(totp).

# Configure

1. create a config file containing your secret token, saved in `~/.mfa/config`
    ```erlang
    {github,"secret1"}.
    {aws,"secret2"}.
    ```
2. run as a escript
    ```
    $ escript mfa.erl
    github: 278048, valid in 25s
       aws: 644852, valid in 25s
    ```
