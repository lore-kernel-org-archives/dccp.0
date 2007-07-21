From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 21 Jul 2007 17:13:18 +0000
Subject: Re: iperf
Message-Id: <200707211813.18317@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thanks - what I did is put the whole thing into a useable format. 

There is now a combined iperf source tarball which has 
     (1) DCCP support, 
     (2) -b switch for CBR mode, 
     (3) TCP pluggable congestion control, and 
     (4) continuous test runs 

all integrated. With the exception of (2), most of these are from your 
patches. The combined tarball comes via

wget http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/zip/iperf-2.0.2_DCCP-patched-CBR-continuous.tar.bz2

I have added description on the CBR mode on the DCCP testing pages on

 http://linux-net.osdl.org/index.php/DCCP_Testing#Testing_with_constant_bitrate


The UDP-Lite variant of iperf has been banned into the UDP-Lite tarball.

|  The only comment on your version is that you remove WIN32 code, and
|  rename some existing options. I had a hope that the code could get
|  merged upstream but my emails to the iperf list haven't succeeded in
|  this (probably because the CAIDA project has no funding).
I fully agree with your comment, but there were reasons - I figured that it will
take a long time until Windows supports both DCCP, plug-able TCP congestion control,
and UDP-Lite; and I found that the code (if it is going to be used under Lunix only)
is much more readable. I can separate out the windows changes into a standalone 
patch, but for the moment I'd much rather put in effort into the test tree.

There is only one flag change:
 * -d  /  --dualtest   becomes `-2' / `--dualtest'
 * -d  /  --dccp       becomes the new switch for DCCP

The other additions were
 * -A <algo>  chooses TCP congestion control algorithm
 * -b now works for UDP and DCCP in the same manner

 
Gerrit
