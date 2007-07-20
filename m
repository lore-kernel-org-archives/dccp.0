From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 20 Jul 2007 12:42:47 +0000
Subject: Re: iperf
Message-Id: <200707201342.47663@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thank you for testing this - the patch had been all in one and apparently 
I have made a bad job of splitting it up into separate patches. 

The error is due to a missing header include (I ported UDP-Lite in 2.6.20
but system headers are not that recent), will fix that and upload a clean
patch set.
|  Applying only patch #1 doesn't work... patch #2 correct the error.
|  PerfSocket.cpp: In function 'void MakeSocket(thread_Settings*)':
|  PerfSocket.cpp:89: error: 'IPPROTO_UDPLITE' was not declared in this scope
|  make[2]: *** [PerfSocket.o] Error 1
|  make[2]: Leaving directory `/root/iperf-2.0.2/src'
|  make[1]: *** [all-recursive] Error 1
|  make[1]: Leaving directory `/root/iperf-2.0.2'
|  make: *** [all] Error 2
|  
|  It could be good to not have 2 iperf dccp patched version, one Ian
|  patched, one Gerrit patched ?
Agree, will look at Ian's patches when I have some time and confer with Ian.

Thanks again.
