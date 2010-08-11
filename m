From: Samuel Jero <sj323707@ohio.edu>
Date: Wed, 11 Aug 2010 16:17:02 +0000
Subject: Re: Problems with idle DCCP connections
Message-Id: <1281543422.1874.38.camel@sjerolaptop.homelinux.net>
List-Id: <dccp.vger.kernel.org>
References: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
In-Reply-To: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> It is probably a bug, the state of the CCID-2 code is not as good as the
> CCID-3 code, the latter has received more attention.
> 
> But you will find several bug CCID-2 bug fixes already contained in the
> DCCP test tree available at
>      git://eden-feed.erg.abdn.ac.uk/dccp_exp   [subtree 'dccp' or 'ccid4']
>      http://[same-address]
> 
> and I would like to ask you to use this tree for testing and bug-fixing, 
> since it is ahead of the mainline tree. I know from testing that the 
> mainline CCID-2 code does not perform very well.

Thanks for the information. I'm compiling the test tree right now. 

I have also done some testing with CCID-3 (Linux 2.6.35 kernel.org tree)
and the same symptoms are present there, but much, much less often.
Maybe once every for every 2 hours the dccp connection is transferring
data, as apposed to once for every 2 minutes in CCID-2.

Samuel Jero

