From: Ian McDonald <imcdnzl@gmail.com>
Date: Tue, 06 Dec 2005 20:01:31 +0000
Subject: Re: initial CCID2 implementation for linux
Message-Id: <cbec11ac0512061201x13d0cf9ajeac2f6b074f5d3e9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20051206190131.GA834@tribal.sorbonet.org>
In-Reply-To: <20051206190131.GA834@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/7/05, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> On Wed, Dec 07, 2005 at 08:29:27AM +1300, Ian McDonald wrote:
> > Can't access that host - appears to be no DNS record.
>
> weird.
> http://128.16.66.93/acme-ccid2-20051206.diff

Cool - can access and starting to look at.

In whole looks good. Will look at more properly later and try to
compile but few initial comments just on code style.

#define DCCP_CCID_TCP			2
#define DCCP_CCID_TFRC			3

I think these should be DCCP_CCID2 and DCCP_CCID3 as there are other
TFRC CCIDs proposed for example. Or maybe DCCP_CCID2_TCP and
DCCP_CCID3_TFRC??

Some issues in ccid2_hc_tx_exit and cci2_hc_rx_init where you have a
space/tab combo at start of some lines.

This code:
static __init int ccid2_module_init(void)
{
	int rc = -ENOBUFS;

	rc = ccid_register(&ccid2);
	if (rc != 0)
		return rc;
	
	return rc;
}

could be:
static __init int ccid2_module_init(void)
{
	return ccid_register(&ccid2);
}

For your new files you need to add your copyright and also GPL
license. You should also add your copyright to files that you modify a
lot.

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
