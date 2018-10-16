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

# How to change existing MFA on github

1. on github, go to Settings -> Security -> Two-factor methods Authenticator app -> Edit -> Set up using an app -> Copy -> Next
2. it will show you a QR code, click on `enter this text code`
3. save the two-factor secret in above `~/.mfa/config` file
4. run the escript, enter the code in github, then click Enable
