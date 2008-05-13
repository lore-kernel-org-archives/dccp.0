From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 May 2008 10:32:19 +0000
Subject: Re: [PATCH] DCCP: Fix to reset the connection with Reset Code 5
Message-Id: <20080513103218.GA28532@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <48294E9C.4060209@cn.fujitsu.com>
In-Reply-To: <48294E9C.4060209@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>
> Sorry for my stupid patch since I can get the test git tree.
>
There is nothing at all wrong with the patch and I apologise for the
remark, since it is not your fault not to be aware of the test tree.

That was my fault - in at least one of the 4 cases David Miller copied the
changeset over to dccp@vger. I am working with Arnaldo de Melo (the DCCP
maintainer) on a solution for this, to avoid future overlap. It is not
your issue, so sorry.

For the moment the best is to apply this patch and fix the problem in
the mainline variant of net/dccp.


> But, Is there any other way to get the git tree? I download a patch from 
> following URL:
>   
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/test-tree_2.6.25.diff.gz
> I used this patch to my linux-2.6.25, there is error happend. and it has 
> compile error too.
This is possible since the snapshots are taken on the day a new release
comes out. Thanks for the notice, the outdated snapshot will be replaced.

>
> Is this patch is based on linux-2.6.25? If I want to send a patch, I  
> must create my patch base on what version of kernel?
>
The test tree tracks the netdev-2.6 kernel and only touches net/dccp. It
can be pulled from
	git://eden-feed.erg.abdn.ac.uk/dccp_exp (subtree `dccp')


Gerrit
