From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 24 Mar 2008 13:07:46 +0000
Subject: Re: dccp bugs
Message-Id: <200803241407.46604.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 24 of March 2008, Gerrit Renker napisa=B3:
> | One more thing I noticed when using dccp...
> | I have a server which accepts connection, receives data and finishes
> | execution and a client that sends 1000 data packets and finishes
> | execution (see http://dccp.one.pl/svn/userspace/test/). When I run
> | ./server then ./client packets are sent but client program finishes
> | executions only after all packets from queue are sent. Which is I guess
> | quite ok. The problem happens when I kill the server program while clie=
nt
> | is running and sending packets. The client detects that the connection =
is
> | broken and starts returning error 32 from sendmsg call.
>
> Error 32 is EPIPEi ("broken pipe"), so this looks correct.
>
> | But after it finishes sending packets it hangs on exit
> | and even kill -9 doesn't work. It finishes after quite a long time (eg.
> | 10 minutes). Am I doing something wrong or is it a bug in dccp? Tested =
on
> | loopback with rate limiting (sudo tc qdisc add dev lo root handle 1:0 t=
bf
> | rate 3kbit burst 3kbit latency 500ms). With rate limiting turned off I
> | don't see any problems. Testing between two virtual machines with rate
> | limiting on shows the same problem.
> | --
>
> Can you try the `ss' command from the iproute package when the problem
> occurs, using `ss -nadep' to display the DCCP states?
>
$ ss -nadep
State       Recv-Q Send-Q                        Local Address:Port        =
                 =20
Peer Address:Port
FIN-WAIT-1  0      0                                 127.0.0.1:2008        =
                    =20
127.0.0.1:29792  ino:0 sk:d301d3c0

> DCCP is connection-oriented, so killing a server/client is different
> from UDP. When you try to kill a DCCP node, it will first try to finish
> its connection. The `hang' effect is most likely due to an uncompleted
> system call such as close(), and it is in a non-interruptible state.
>
10 minutes for an uninterruptible call seems to be quite a long time. If I =

were a system administrator it would probably drive me mad.

> What is far more important to know - are you using a standard kernel, a
> netdev kernel, or the test tree? And from what you describe, I suspect
> you are using CCID-3 - does the same problem happen with CCID-2?
>
I'm using not that fresh DCCP experimental tree. Tested on CCID-2 but same =

thing happens on CCID-3.

> I am aware that there is at least one patch which may remedy the problem
> you encountered, which is the patch to clean up the write queue on
> (forced) disconnect, also the wait-for-ccid cleanup routine which
> flushes the write queue at the end of the connection.
>
Is it in experimental tree?

> There are also sysctls to reduce the number of attempts to repeat a
> (futile) close at the end, in Documentation/networking/dccp.txt
You mean the *retries* entries? Setting all three to 1 doesn't make it any =

better.

And one more thing: if I try to interrupt the client program before it reac=
hes=20
its end all is fine - the program finishes execution immediately.
--=20
Regards,
Tomasz Grobelny
