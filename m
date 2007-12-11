From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 11 Dec 2007 17:40:43 +0000
Subject: Re: [Announce]: Test results with latest CCID3 patch set
Message-Id: <20071211174043.GG24046@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Dec 11, 2007 at 02:21:28PM +0000, Gerrit Renker escreveu:
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
> 
>  * the built-in VoIP module only works for UDP -- is it possible to port this to DCCP?
>  
>  * as per previous email, more complex traffic scenarios would be good, in particular
>    - switching on/off background traffic at times to observe TCP/flow-friendliness
>    - running multiple DCCP flows in parallel and at overlapping times 

Does this tool records results in a database keyed by kernel
version/buildid for us to use it as a regression tool?

Something that would produce results around these lines:

"WARNING: test #23 counter #3 variance bigger than specified since the
last kernel tested (git cset 55ed793afb4a8025d33a8e6a5f2f89d5ac4d8432)!"

- Arnaldo
