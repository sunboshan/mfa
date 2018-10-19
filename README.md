# mfa

`mfa` is a tool to generate time-based one time password(totp).

# Prerequisite

1. install Erlang/OTP 21.

# Configure

1. create a config file containing your secret token, saved in `~/.mfa/config`
    ```erlang
    {github,"secret1"}.
    {gitlab,"secret2"}.
    ```
2. run as a escript
    ```
    $ escript mfa.erl
    github: 278048, valid in 25s
    gitlab: 644852, valid in 25s
    ```

# How to change existing MFA on github

1. on github, go to Settings -> Security -> Two-factor methods Authenticator app -> Edit -> Set up using an app -> Copy -> Next
2. it will show you a QR code, click on `enter this text code`
3. save the two-factor secret in above `~/.mfa/config` file
4. run the escript, enter the code in github, then click Enable

# How to hack MFA?

`hack.erl` module demonstrates how to brute force a 3-bytes key.

```erlang
$ erl

1> hack:run().
Key is <<62,95,238>>, hotp for 89 is 920752
potential key found     <<0,50,21>>, hotp is 920752
potential key found   <<62,95,238>>, hotp is 920752
potential key found  <<97,105,139>>, hotp is 920752
potential key found <<113,102,172>>, hotp is 920752
potential key found <<114,162,217>>, hotp is 920752
...
*** found key <<62,95,238>> in 16s ***
```

`phack.erl` module demonstrates how to parallel brute force a n-bytes key using all CPUs.

```erlang
2> phack:run(3).
Started 12 worker processes.
<0.88.0>
Random generated key is <<243,224,148>>, hotp for 000684 is 286344
potential key  <<214,30,114>> found by worker <0.91.0>, hotp is 286344
potential key   <<86,106,16>> found by worker <0.97.0>, hotp is 286344
potential key  <<152,74,219>> found by worker <0.94.0>, hotp is 286344
potential key   <<25,48,101>> found by worker <0.100.0>, hotp is 286344
potential key <<113,197,202>> found by worker <0.96.0>, hotp is 286344
potential key  <<199,117,98>> found by worker <0.92.0>, hotp is 286344
potential key <<220,116,102>> found by worker <0.91.0>, hotp is 286344
potential key <<243,224,148>> found by worker <0.90.0>, hotp is 286344
key <<243,224,148>> found by worker <0.90.0> in 1s
```

# Note

1. The whole point for MFA is to have an extra layer security, using this tool
will make that extra layer security go away. Use with caution.
2. The base32 decode implementation in `mfa.erl` didn't count for key encoded
with padding `=`.
