From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 29 Aug 2008 06:12:37 +0000
Subject: Re: [PATCH 07/37] dccp: Registration routines for changing feature
Message-Id: <20080829061237.GD3557@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > +/* check that SP values are within the ranges defined in RFC 4340 */
| > +static u8 dccp_feat_is_valid_sp_val(u8 feat_num, u8 val)
| > +{
| > +	switch (feat_num) {
| > +	case DCCPF_CCID:
| > +		return val = DCCPC_CCID2 || val = DCCPC_CCID3;
| 
| Shouldn't we look at the registered CCIDs and do validation based on the
| modules loaded? Doing it this hardcoded way will prevent testing CCID4,
| for instance, or require that the kernel be patched, which can not be
| possible with enterprise distros, etc. And defeats the purpose of having
| multiple pluggable congestion control algorithms :-)
| 
The point is valid and actually such a check is done, see further below.

In the CCID-4 subtree, the above statement changes to
 | > +		val >= DCCPC_CCID2 && val <= DCCPC_CCID4;
The above function only serves as sanity-check for SP values, so that no
unknown values appear. There is a registry for CCID identifiers, only
ones that are in RFC documents are "valid". With regard to RFC 4340,
19.5 we could consider adding the experimental identifiers here
(248-254 are valid, we could use one for the "UDP-like" CCID).	

With regard to doing validation based on the modules loaded, the
mechanism works as follows:
 1. at socket initialisation time dccp_init_sock calls dccp_feat_init
 2. dccp_feat_init queries the compiled-in CCIDs:
        /*
         * We advertise the available list of CCIDs and reorder according to
         * preferences, to avoid failure resulting from negotiating different
         * singleton values (which always leads to failure).
         * These settings can still (later) be overridden via sockopts.
         */
        if (ccid_get_builtin_ccids(&tx.val, &tx.len) ||
            ccid_get_builtin_ccids(&rx.val, &rx.len))
                return -ENOBUFS;
    => If it succeeds, the `tx' and `rx' entries will be identical copies.

 3. The next step in dccp_feat_init is to try and load all configured  CCIDs:

        if (ccid_request_modules(tx.val, tx.len))
                goto free_ccid_lists;

    => If this succeeds, the host is ready to answer to any request by
	the peer.

 4. Finally, if the peer tries to negotiate an unknown CCID, negotiation
    will fail as per the server-priority negotiation rules (6.3.1), unless
    the peer has an entry in its CCID list which agrees with an entry of
    our list.
