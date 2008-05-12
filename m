From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 12 May 2008 06:48:56 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: cmsg header parsing fixes
Message-Id: <20080512064856.GB4940@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080502202242.74967BC4D@poczta.oswiecenia.net>
In-Reply-To: <20080502202242.74967BC4D@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > I don't know what your extension plans are, my suggestion is to wrap up
| > the patches in the qpolicy subtree, cast them as one patch within the
| > test tree and continue any additions/further work based on that.
| >
| Agreed, the only thing that may need correction now is this line:
| 	skb->priority = *(__u32 *)CMSG_DATA(cmsg);
| But I really don't know how it should look like, and I have neither knowledge 
| nor machines to test on other architectures. 
After a further look, I think your code is in fact correct. The data portion
is always either 32-bit or 64-bit aligned:

#define CMSG_ALIGN(len) ( ((len)+sizeof(long)-1) & ~(sizeof(long)-1) )
#define CMSG_DATA(cmsg) ((void *)((char *)(cmsg) + CMSG_ALIGN(sizeof(struct cmsghdr))))


Further, casting into various types is done quite freely throughout the code:

577  net/ipv6/datagram.c <<datagram_send_ctl>>
        fl->fl6_flowlabel = IPV6_FLOWINFO_MASK & *(__be32 *)CMSG_DATA(cmsg);
704  net/ipv6/datagram.c <<datagram_send_ctl>>
        *hlimit = *(int *)CMSG_DATA(cmsg);
59  net/rxrpc/ar-output.c <<rxrpc_sendmsg_cmsg>>
        *user_call_ID = *(u32 *) CMSG_DATA(cmsg);
75  net/rxrpc/ar-output.c <<rxrpc_sendmsg_cmsg>>
        *abort_code = *(unsigned int *) CMSG_DATA(cmsg);


| Other than that we could consider the patch ready.
| 
I will post it subsequently. If you are ok with it, add your signed-off
line and I will put it into the tree; if anything is unclear or needs
further consideration, let me know.


| As for my extension plans, I can see a few things that could be improved:
|  - adding timeout parameter,
|  - providing information about available qpolicies and parameters to 
| userspace,
|  - providing statistical information about qpolicy to userspace applications.
| (That doesn't necessarily mean I wish to write patches for all these 
| features.)
| -- 
Once the patch is in the test tree, we can keep the qpolicy subtree for
further development/testing. Regarding statistics, there is a MIB in the
code already (dccp_statistics), but when compiled as a module the
statistics do not show up under /proc/net/snmp or /proc/net/snmp6 -
maybe it works when compiling all of DCCP into the kernel.

Gerrit


The University of Aberdeen is a charity registered in Scotland, No SC013683.

