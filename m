From: Burak Gorkemli <burakgmail-dccp@yahoo.com>
Date: Thu, 13 Dec 2007 13:28:48 +0000
Subject: Re: [Announce]: Test results with latest CCID3 patch set
Message-Id: <75619.32740.qm@web30008.mail.mud.yahoo.com>
List-Id: <dccp.vger.kernel.org>
References: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

I am cloning your tree with the following command:

    git-clone git://eden-feed.erg.abdn.ac.uk/dccp_exp my_dccp


But I did not check out the DCCP sub-branch, by:

    git-checkout --track -b dccp origin/dccp


However, as I type this command above, git complains saying:

    git checkout: branch dccp already exists


It this OK to say so?
 
--
Burak

----- Original Message ----
> 
> Burak
> 
> I have tried to replay your results but can not find anything
> wrong
> 
 with the current test kernel.
> Please have a look at the results below, I repeated the same
> experiment
> 
 on two different testbeds.
> 
> Incidentally, these results agree with the values you observed for
> TCP
> 
 Reno. It seems that the
> setup is not right, I am happy to help debugging this but I don't
> think
> 
 that there is a problem
> with the test kernel.
> 
> Can you please describe your setup - maybe something went wrong.
> 
> The first thing to check is whether you are really using the test
> tree
> 
 - it is necessary to check
> out the `dccp' subtree, if you are on the `master' instead of
> the
> 
 `dccp' subtree, then you are
> using a vanilla 2.6.24-rc5.  A detailed HowTo is on
>        
> 
 http://www.linux-foundation.org/en/Net:DCCP_Testing#Experimental_DCCP_source_tr
> ee
> The difference can also easily be told in the
> Request/Response
> 
 handshake, the CCIDs are now
> fully negotiated; the first value of the ConfirmL/R in
> the
> 
 DCCP-Response says which CCIDs are
> used (but they are still nonetheless set
> via
> 
 net.dccp.default.{rx,tx}_ccid).
> 

<snip>

