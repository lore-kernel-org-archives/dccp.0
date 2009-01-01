From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 01 Jan 2009 10:49:23 +0000
Subject: Re: [RFC] [Patch 2/4] dccp: Lockless use of CCID blocks
Message-Id: <20090101104923.GA4269@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20081220080813.GC3853@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20081220080813.GC3853@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| | > +	for (i = 0; i < ARRAY_SIZE(ccids); i++)
| | > +		if (ccids[i]->ccid_id = id)
| | > +			return ccids[i];
| | > +	return NULL;
| | 
| | Why the we searching? Can't we just do:
| | 
| | {
| | 	if (id > ARRAY_SIZE(ccids) - 2)
| | 		return NULL;
| | 	return ccids[id - 2];
| | }
| | 
| Agree 100%, I don't like the routine myself and have been thinking about
| how to rewrite it. Current idea is to go back to the original and use
| 
| static struct ccid_operations *ccids[CCIDS_MAX] = {
| 	[DCCPC_CCID2] = &ccid2_ops,
| #ifdef CONFIG_IP_DCCP_CCID3
| 	[DCCPC_CCID3] = &ccid3_ops,
| #endif
| };
| 
Unfortunately I found later that this solution introduces a lot of waste: 
during initialisation, the code must step over 255 - 2 = 253 NULL entries
and the same happens when ejecting the CCID.

I went through several revisions and summarize the findings below.

The following functions need to query for built-in CCIDs:

bool ccid_support_check(u8 const *ccid_array, u8 array_len);
   This is used by the feature-negotiation code to determine whether
   all elements in 'ccid_array' are supported; for checking the CCID
   setsockopt values and to check whether the CCID suggested by the
   peer is locally available.

int ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len);
   This is used during initialisation of the feature-negotiation code,
   to create a list of the CCID values that can be advertised.

int ccid_getsockopt_builtin_ccids(struct sock *sk, int len, ...);
   Used to provide the DCCP_SOCKOPT_AVAILABLE_CCIDS getsockopt option
   which passes a list of available CCIDs to userspace.
   
struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx, ...);
   This function is called by the CCID handler in feat.c to set the RX/TX	
   CCID after it has been negotiated with the peer.


The first 3 functions can be implemented by simply walking through the
array, the last one requires to map a CCID value (Table 5 in RFC 4340,
10) into an array index. In the above, CCID ID = array index but only
2 out of 256 possible IDs (0..255) are non-empty (less than 0.8%).

Furthermore, the CCIDs need not be in consecutive order. For example
CCID-248 .. CCID-254 are experimental (RFC 4340, 19.5), so we could
have an array like

 struct ccid_operations *ccids[] = {
	 &ccid2_ops, &ccid3_ops, &ccid247_ops, &ccid254_ops
 };

This gives the mapping 0 +-> 2, 1 +-> 3, 2 +-> 247, 3 +-> 254. The
ccid_new() function needs the inverse mapping, e.g. for CCID-247 it
needs to find the third array entry.

So we have the choice of
 * O(1) access for ccid_new() when using an array with 256 entries,
   but have to pay the price of more complex registration /
   unregistration routines. In addition, the 'get_builtin_xxx'
   routines need to make two passes instead of one, to determine
   the number of non-NULL entries.
 * O(n) linear search to map a CCID number into the corresponding
   array index, but simpler implementation of several routines.

Since n is much smaller than 255, I think the latter is better here.

[patch is on the way, need to finish testing]
