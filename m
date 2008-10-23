From: gerrit@erg.abdn.ac.uk
Date: Thu, 23 Oct 2008 05:18:56 +0000
Subject: Re: Protocol not attached
Message-Id: <41104.148.187.160.35.1224739136.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>
> We've tested using netdev tree and it is working.
>
Unfortunately, the fact that it works under the Linus tree and under the
netdev-2.6 tree does not mean that the cause of the problem has gone.

This is because the request_module calls from the DCCP tree are missing.
So one could test by

 1) trying the DCCP patch on the Linus tree
    http://eden-feed.erg.abdn.ac.uk/latest-dccp-test-tree.diff.gz

 2) check netdev-2.6 + DCCP patches -- but you already tested this
    and it was the reason for this thread.

Looking at your .config file again yesterday I noted that it sets
 # CONFIG_64BIT is not set
 CONFIG_X86_32=y
 # CONFIG_X86_64 is not set
 CONFIG_X86=y,

i.e. you are compiling a 32 bit kernel on a 64bit (Athlon) processor. On
the Sempron I use a 64 bit kernel and it works. Yesterday evening I tried
(with some difficulties) to build the 32-bit variant and, ecce, after
building it it hung in a call to request_modules for a binformat module.

Hence I think that one likely cause may be a 32/64 bit issue. Did you notice
any other module-related build problems on the 32 bit kernel? Earlier you
mentioned that SCTP also was not working.

There are other parts of the (networking) system that also call
request_module, (grep -R request_module net/), for instance if TCP
pluggable congestion control is built as a module -- I take it this is
working correctly?

Gerrit

 CONFIG_64BIT=y
 # CONFIG_X86_32 is not set
 CONFIG_X86_64=y


