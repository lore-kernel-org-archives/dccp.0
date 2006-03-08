From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Wed, 08 Mar 2006 12:51:37 +0000
Subject: Re: Report: feat negot state
Message-Id: <20060308125137.GA10158@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
In-Reply-To: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Mar 07, 2006 at 12:05:51AM -0300, Arnaldo Carvalho de Melo wrote:
> With the current patch, available at:
> 
> http://oops.ghostprotocols.net:81/acme/dccp_minisock.patch


Great work.  I see you've been busy lately =D  Anyway, I'll comment inline, and
then write a bunch of random thoughts at the end.


+	struct list_head	     dccpms_pend;
+	struct list_head	     dccpms_conf;

good.  only 2 queues:  one for "pending changes" and one for confirms.  You
might have wondered why i had a "confirm" inside the pending change queue
itself, and then a seperate confirm queue.

Basically, because i coded server priority features first, and then
non-negotiable.  With NN features, you need to send confirms even for stuff you
don't know about [or something like that] so i didn't know where to shove the
confirm =D

Anyway, it's much better like this [i was planning to do it at some point, but i
just "died"]
 
 
 	/* Check if nothing is being changed. */
-	if (ccid_nr = new_ccid_nr)
+	/* XXX handle multibyte values */
+	if (ccid_nr = *val)
 		return 0;


ccid can only be 1 byte.  kill comment.  assert(len = 1);

-
-	new_ccid = ccid_new(new_ccid_nr, sk, rx, GFP_ATOMIC);
+#if 0
+	new_ccid = ccid_new(*val, sk, rx, GFP_ATOMIC);
 	if (new_ccid = NULL)
 		return -ENOMEM;


that if 0 is only for your debug right?
		
 	
 	switch (feat) {
 	case DCCPF_CCID:
-		return dccp_feat_update_ccid(sk, type, val);
+		return dccp_feat_update_ccid(dmsk, type, val, len);

update_ccid() shouldn't care about len.  it knows the length of ccid.  Well I
guess it depends on who you leave it to do sanity checks.  But by the time the
option is "negotiated", errors would have been spotted by upper layers.  [For
example when doing server priority reconciliation.]

+	feat->dccpf_conf_idx = sidx;
+	feat->dccpf_conf_len = rlen;

conf_len should be the length of the option itself, not the length of the
feature list.  I guess this will be sorted when we work on the multi-byte patch.

 	
 	/* update the option on our side [we are about to send the confirm] */
-	rc = dccp_feat_update(sk, opt->dccpop_type, opt->dccpop_feat, *res);
+	rc = dccp_feat_update(dmsk, feat->dccpf_type, feat->dccpf_feat,
+			      spref + sidx, 1);

similar problem.  Hardcoded feature length of 1.  perhaps it should be
feat->dccpf_conf_len.

 

+			feat->dccpf_conf_idx = 0;
+			feat->dccpf_conf_len = 1;

should the index be sidx?  Also, same problem with legnth.


-	/* generate the confirm [if required] */
-	dccp_feat_flush_confirm(sk);
-
+	/* Confirms will be sent on the next packet */

yea but what if the next packet is never sent?  I.e. uni-directional connection.
There should be a mechanism to  force an ack after X amount of time if the dude
doesn't talk.


+	list_for_each_entry(feat, &dmsk->dccpms_pend, dccpf_node) {
+		if (!dccp_feat_negotiated(feat) &&
+		    feat->dccpf_type = t &&
+		    feat->dccpf_feat = feature) {
+			feat->dccpf_conf_idx = 0;
+			feat->dccpf_conf_len = len;

is the index correct?  Also, len should be length of option not of preference
list.  Confirms will contain confirmed value + pref list.

+			/* We got a confirmation: change the option */
+			dccp_feat_update(dmsk, feat->dccpf_type,
+					 feat->dccpf_feat, val, len);

i'm not sure feat_update should care about length [unless IT sanity checks].  If
so, len should be of value, not pref list.

-	if (all_confirmed) {
-		dccp_pr_debug("clear feat negotiation timer %p\n", sk);
-		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
 	}

so what's the story with timers?  Did you kill them?  Will changes be
re-transmitted?

 
+	rc = dccp_feat_change(dmsk, DCCPO_CHANGE_L, DCCPF_ACK_RATIO,
+			      &dmsk->dccpms_ack_ratio, 1, gfp);

ack ratio is 2 bytes i think.


+	case DCCPF_CCID:
+		return len >= sizeof(__u8);

should it also have an && <= number_of_ccids at this point?  Breaks modular
architecture =D  But you hardcoded MAX_FEATURE_VALUE or whatever it's called
anyway =D


 	/* confirm any options [NN opts] */
-	list_for_each_entry_safe(opt, next, &dp->dccps_options.dccpo_conf,
-				 dccpop_node) {
-		dccp_insert_feat_opt(skb, opt->dccpop_type,
-				     opt->dccpop_feat, opt->dccpop_val,
-				     opt->dccpop_len);
-		/* fear empty confirms */
-		if (opt->dccpop_val)
-			kfree(opt->dccpop_val);
-		kfree(opt);

I belive the "confirm queue" now contains confirms for SP and NN options... so
you can probably kill the [] in the comment.
 
 		
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  inet_csk(sk)->icsk_rto, DCCP_RTO_MAX);
-	}

again... change requests are reliable.


==========
OK I think it's a great tidy up and addition of very good code.  I would suggest
the following:

1) Merge it
2) I'll try to re-write the multi-byte feature support patch.  I believe this is
   important functionality which is missing.


So now feature negotiation is moved into the minisock stuff.  I don't know what
it means exactly, but i think the minisock stuff is the socket created upon
receiving a SYN... i.e. a half open connection.  The idea is to keep as little
state as possible in order to avoid SYN floods and other lame dos attacks.

While I was writing feature negotiation, I spotted quite a nice dos attack.
Actually, probably it sucks, but here it is.

The idea is that when you send a REQUEST, you can include your CHANGE options.
The server will RESPOND with the various CONFIRM options.  Here are the nice
implications of this:

* The server must remember which CONFIRMs it sent.  [In fact, the previous code
  was bugged because of this I think---it would remember the features of ALL
  clients in a single socket... anyway.]

  This means that the server must not trash memory, it has to hold some state,
  and potentially even setup those options.  E.g. it might have to load a CCID,
  etc etc.

* The server must actually calculate the CONFIRMS.  With server priority, the
  calculation works as follows:  Given preference list C and S of the client and
  server respectively, the winning value is the first value which appears in S
  and also in C.

  Basically:

  for each s in S
    for each c in C
      if (s = c)
        w00t();

Therefore, would the following DoS DCCP:
* Send a bunch of change options for a SP option in the REQUEST.  Provide an
  ultra long feature list which will not mathc anything on the server, or maybe,
  the last byte will match or something like that.

* The server will have to scan the whole list and compare it against its own
  stuff.

I'm not sure you can write a generic "fast calculation" algorithm as it is not
mandatory to sort the preference lists in any way.  
