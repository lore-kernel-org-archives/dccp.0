From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 20 Jul 2007 12:35:02 +0000
Subject: Re: iperf
Message-Id: <200707201335.02745@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  OK. I've hacked my iperf version around a bit to get closer to Gerrit's.
|  
|  What I've done:
|  - ported more of his code over
|  -- renaming/shifting code
|  -- fix service code handling to allow network byte order and correct name
|  -- merged using -b option for DCCP (NB gives an error at end but seems
|  to be working OK)
This is an error - you need to support the -b option on the server as well. The
reason is that iperf, like ttcp, uses a kind of handshake to terminate datagram 
test runs. You didn't describe the error - was it something like `did not receive the
last ack after 10 tries'? If yes then the code needs to support -b on the server
as well. The bandwidth measurements are otherwise not accurate.

|  
|  Our code still differs a bit e.g. I don't support UDP Lite yet.
Are these the only differences? If yes then I am all for combining one patch 
and uploading it to the description of regression testing.

Over the time I have using -b (even if it does not solve the present problem
with bandwidth) a very useful diagnosis tool, iperf at full speed generates
a lot of noise.
