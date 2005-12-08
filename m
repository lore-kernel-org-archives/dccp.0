From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 08 Dec 2005 07:12:41 +0000
Subject: Re: initial CCID2 implementation for linux
Message-Id: <4397DCE9.1090508@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <20051206190131.GA834@tribal.sorbonet.org>
In-Reply-To: <20051206190131.GA834@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi, just a note:

The official names of CCID2 and CCID3 are "TCP-Like Congestion Control" and 
"TFRC Congestion Control".  So DCCP_CCID_TCPLIKE and DCCP_CCID_TFRC are 
perfectly reasonable.  Any TFRC variant that's not CCID3 will likely get a 
different name.

Eddie


Ian McDonald wrote:
> On 12/7/05, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> 
>>On Wed, Dec 07, 2005 at 08:29:27AM +1300, Ian McDonald wrote:
>>
>>>Can't access that host - appears to be no DNS record.
>>
>>weird.
>>http://128.16.66.93/acme-ccid2-20051206.diff
> 
> 
> Cool - can access and starting to look at.
> 
> In whole looks good. Will look at more properly later and try to
> compile but few initial comments just on code style.
> 
> #define DCCP_CCID_TCP			2
> #define DCCP_CCID_TFRC			3
> 
> I think these should be DCCP_CCID2 and DCCP_CCID3 as there are other
> TFRC CCIDs proposed for example. Or maybe DCCP_CCID2_TCP and
> DCCP_CCID3_TFRC??
> 
> Some issues in ccid2_hc_tx_exit and cci2_hc_rx_init where you have a
> space/tab combo at start of some lines.
> 
> This code:
> static __init int ccid2_module_init(void)
> {
> 	int rc = -ENOBUFS;
> 
> 	rc = ccid_register(&ccid2);
> 	if (rc != 0)
> 		return rc;
> 	
> 	return rc;
> }
> 
> could be:
> static __init int ccid2_module_init(void)
> {
> 	return ccid_register(&ccid2);
> }
> 
> For your new files you need to add your copyright and also GPL
> license. You should also add your copyright to files that you modify a
> lot.
> 
> Ian
> --
> Ian McDonald
> http://wand.net.nz/~iam4
> WAND Network Research Group
> University of Waikato
> New Zealand
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
