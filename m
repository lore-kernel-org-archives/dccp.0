From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Sep 2008 05:12:16 +0000
Subject: Re: [PATCH 25/37] dccp: Feature activation handlers
Message-Id: <20080904051216.GB3768@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-26-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-26-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> These conditions (should) ensure that the above condition is never
>> triggered, the test is like an assert() clause.
>>   
>
> This special case it is not as you said. The packet seq as following:
>
> Endpoint A                    Endpoing B
> REQUEST        --------->
> (CHANGE L/unknow feature)
>               <---------     RESPONSE
>                              (CONFIRM R/empty unknow feature)
> ACK            ---------->
>                              call dccp_feat_activate_values()
>                              -->print DCCP_BUG("Unknown feature %u", cur->feat_num);
>
>
> After Endpoint B send REPONSE with empty CONFIRM R option, the unknow
> feature is *still remain* in the feature list. dccp_feat_insert_opts()  
> never clean up
> those features. So here we can get idx < 0. Features with is not needed  
> is clean up
> after active the feat value in dccp_feat_activate_values().
>
> int dccp_feat_activate_values(struct sock *sk, struct list_head *fn_list)
> {
>    ...
>    list_for_each_entry_safe(cur, next, fn_list, node)
>        if (!cur->needs_confirm)
>            dccp_feat_list_pop(cur);
>    ...
> }
>
You are right, this is an oversight.

In an earlier revision the code actually removed Confirm options
immediately, or as soon as the request socket was cloned. Here is an
early RCS revision of the patch for dccp_feat_insert_opts():

+		if (pos->state = FEAT_INITIALISING)
+			pos->state = FEAT_CHANGING;
+		else if (pos->needs_confirm && dreq = NULL)
+			dccp_feat_list_pop(pos);

But then there was the problem that if Confirm options are not retransmitted
for robustness, feature negotiation fails if packets are lost (e.g. the Ack
completing the initial handshake). This was first reported by Leandro, full story on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/why_retransmit_confirms
(That fix is not part of this patch set, it comes in the second part.)

But after the above "pop" had been removed, the assumption that only "clean"
options are in the feature list is no longer valid.

Modifying the above to work only for empty Confirm's would take away the
advantage of retransmission. The pop() would also not work, while your earlier
suggestion of skipping over empty Confirms does:

+int dccp_feat_activate_values(struct sock *sk, struct list_head *fn_list)
...	
+       list_for_each_entry(cur, fn_list, node) {
+               if (cur->empty_confirm)
+                       continue;
...

This is because Confirm options are retransmitted even after activation.

Many thanks indeed.
