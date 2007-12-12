From: Alessio Botta <a.botta@unina.it>
Date: Wed, 12 Dec 2007 23:19:11 +0000
Subject: Re: [Announce]: Test results with latest CCID3 patch set
Message-Id: <47606C6F.3090100@unina.it>
List-Id: <dccp.vger.kernel.org>
References: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



Gerrit Renker ha scritto:
> | I am new of this mailing list and I am really interested in the
> | measurements you are performing with DCCP.
> This was more of a regression test, as there had been recent changes in
> the test tree, to see that the kernel (not userspace) still performs in
> a predictable way.
> 
> | Which tool are you using ? Are you using Iperf for such measurements ?
> The setup is the one from
> 	http://www.linux-foundation.org/en/Net:DCCP_Testing#Regression_testing
> and, yes, it uses iperf.	
> 
> | Have you ever heard about D-ITG ?
> 
> | You can find more information here:
> | http://www.grid.unina.it/software/ITG
> | 
> | I am one of the authors of such platform and I have also
> | performed some very preliminary tests with DCCP.
> | 
> | I would be very glad to have your opinion on that and I'm very interested
> | in improving its features, also with specific regard to the support of
> | transport protocols.
> | 
> It is a very nice tool with many features. I only ran simple tests with it (version 2.6),
> again only as basic sanity tests -- the throughput result was similar to the one tested with
> iperf.
> 
> I think that the tool has more to offer and can help improve/extend DCCP testing.
> Here is my list of points, hoping that the others will add theirs, too:
> 
>  * would be good to have a standardised set of scripts, for comparison/benchmarking

I can provide you the necessary support to verify the scripts and also 
to start to
set up them. However, I need to know what you would like to generate.

I have seen on the web page reported above the kind of tests you are 
performing
with iperf, and I would like to provide you some some pieces of useful 
information
regarding D-ITG. This tool allows to set two random variables that control
the characteristics of traffic you generate. One of these variables 
models the Inter
Departure Time (IDT) and the other one models the Size (PS) of the 
Packets. As of now,
we support 6 random variables that are exponential, gamma, normal, 
pareto, cauchy,
and poisson. Clearly also constant IDT and PS can be set.

 From the web page reported above I have seen that with iperf you 
generate CBR
traffic but I could not find the rate.

Moreover, in order to standardize the tests I need to know how you 
measure the
obtained bit-rate. D-ITG can log at both sender and receiver sides 
different information
for each sent and received packet respectively. Therefore after the 
tests you can
obtain different information by analyzing the log files (with ITGDec). 
Regarding the
bit-rate, you can have an average value related to the complete 
generation period as
well as related to smaller time intervals.

> 
>  * the built-in VoIP module only works for UDP -- is it possible to port this to DCCP?

The VoIP traffic is produced by setting an appropriate IDT and PS which 
are basically
constant and printed out on standard output when a VoIP traffic flows is 
about to be
generated. Therefore, you can already perform VoIP tests with DCCP.
For more information you can have a look at D-ITG manual:
http://www.grid.unina.it/software/ITG/codice/D-ITG2.6-manual.pdf

If you can not find all the necessary information, just ask me.

>  
>  * as per previous email, more complex traffic scenarios would be good, in particular
>    - switching on/off background traffic at times to observe TCP/flow-friendliness

D-ITG supports multi-flow operation mode. In this case it reads the 
input information
from a script file instead of the standard input. It uses a thread for 
each requested flow
therefore the flows can have completely different characteristics in 
terms of kind of
traffic (IDT and PS models), duration, start time, and transport protocols.

>    - running multiple DCCP flows in parallel and at overlapping times 

This is already possible thanks to the script mode.

> 
> 
> Gerrit   

Alessio
