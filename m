From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 02 Sep 2008 06:12:21 +0000
Subject: Re: [PATCH 07/37] dccp: Registration routines for changing feature
Message-Id: <48BCD945.1020009@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> | > +/* check that SP values are within the ranges defined in RFC 4340 */
> | > +static u8 dccp_feat_is_valid_sp_val(u8 feat_num, u8 val)
> | > +{
> | > +	switch (feat_num) {
> | > +	case DCCPF_CCID:
> | > +		return val = DCCPC_CCID2 || val = DCCPC_CCID3;
> | 
> | Shouldn't we look at the registered CCIDs and do validation based on the
> | modules loaded? Doing it this hardcoded way will prevent testing CCID4,
> | for instance, or require that the kernel be patched, which can not be
> | possible with enterprise distros, etc. And defeats the purpose of having
> | multiple pluggable congestion control algorithms :-)
> | 
> The point is valid and actually such a check is done, see further below.
>
> In the CCID-4 subtree, the above statement changes to
>  | > +		val >= DCCPC_CCID2 && val <= DCCPC_CCID4;
>   

This may cause DCCP client which support only CCID 2 and CCID 3 can not 
connect to a DCCP server which support CCID2 to CCID4.

See as following:

DCCP client                    DCCP server
REQUEST           ------->
(CHANGE_R/CCID 2 3)
                  <-------     RESPONSE
                               (CONFIRM_R/CCID 2 2 3 4)


RESPONSE from DCCP server with CONFIRM_R(CCID 2 2 3 4) will cause DCCP 
client send a reset to DCCP server.

This is because dccp_feat_confirm_recv() will check whether the feat 
list is valid before accept the CCID.

static u8 dccp_feat_confirm_recv(struct list_head *fn, u8 is_mandatory, 
u8 opt, ... {
    ...
    if (!dccp_feat_sp_list_ok(feat, val, len))
        goto confirmation_failed;
    ...
}


> The above function only serves as sanity-check for SP values, so that no
> unknown values appear. There is a registry for CCID identifiers, only
> ones that are in RFC documents are "valid". With regard to RFC 4340,
> 19.5 we could consider adding the experimental identifiers here
> (248-254 are valid, we could use one for the "UDP-like" CCID).	
>
> With regard to doing validation based on the modules loaded, the
> mechanism works as follows:
>  1. at socket initialisation time dccp_init_sock calls dccp_feat_init
>  2. dccp_feat_init queries the compiled-in CCIDs:
>         /*
>          * We advertise the available list of CCIDs and reorder according to
>          * preferences, to avoid failure resulting from negotiating different
>          * singleton values (which always leads to failure).
>          * These settings can still (later) be overridden via sockopts.
>          */
>         if (ccid_get_builtin_ccids(&tx.val, &tx.len) ||
>             ccid_get_builtin_ccids(&rx.val, &rx.len))
>                 return -ENOBUFS;
>     => If it succeeds, the `tx' and `rx' entries will be identical copies.
>
>  3. The next step in dccp_feat_init is to try and load all configured  CCIDs:
>
>         if (ccid_request_modules(tx.val, tx.len))
>                 goto free_ccid_lists;
>
>     => If this succeeds, the host is ready to answer to any request by
> 	the peer.
>
>  4. Finally, if the peer tries to negotiate an unknown CCID, negotiation
>     will fail as per the server-priority negotiation rules (6.3.1), unless
>     the peer has an entry in its CCID list which agrees with an entry of
>     our list.
>   

