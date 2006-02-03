From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Fri, 03 Feb 2006 19:02:33 +0000
Subject: Comments on the feature negotiation patch
Message-Id: <39e6f6c70602031102t672a5310k871a3d5047163557@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Andrea,

    Now that I have merged the ackvec record and ccid2 patches could
you please address
my initial concerns with the feature negotiation patch?

Patch reviewed:  http://128.16.66.93/acme-dccp-feat.diff

+struct dccp_opt_pend {
+	struct list_head	dccpop_list;

Please name this as "dccpop_node", "_list" implies that this member
contains a list, and not
that it is part of a list (dccpo_pending)

+	u8			dccpop_type;
+	u8			dccpop_feat;

+	__u8			dccpo_send_ndp_count;

Try to be consistent with types, using __u8 instead of u8 and unsigned
char when the struct is
to be visible only in the kernel build process.

+int dccp_feat_change(struct sock *sk, u8 type, u8 feature, u8 *val, u8 len,
+		     gfp_t gfp)
+{
+	struct dccp_opt_pend *opt;
+	struct dccp_sock *dp;
+	
+	dccp_pr_debug("feat change type=%d feat=%d\n", type, feature);
+
+	/* check if that feature is already being negotiated */
+	dp = dccp_sk(sk);

In these cases it saves some lines and thus is the preferred form to have dp
assigned at its declaration place, like:

          struct dccp_sock *dp = dccp_sk(sk);

+	/* negotiation for a new feature */
+	opt = kmalloc(sizeof(*opt), gfp);
+	if (!opt)
+		return -ENOMEM;
+
+	memset(opt, 0, sizeof(*opt));

Use kzalloc, replacing kmalloc + memset(0)

+	/* check if we are the black sheep */
+	if (dp->dccps_role = DCCP_ROLE_CLIENT) {
+		spref = rpref;
+		slen = rlen;
+		rpref = opt->dccpop_val;
+		rlen = opt->dccpop_len;
+	}
+	else {

Please use:

           } else {

+		default:
+			BUG(); /* XXX implement res */
+		}

This is a bit extreme, WARN_ON(1) please.

+	/* put it in the "confirm queue" */
+	if (!opt->dccpop_sc) {
+		opt->dccpop_sc = kmalloc(sizeof(*opt->dccpop_sc), GFP_ATOMIC);

Sure that dccp_feat_reconcile can't be called from process context (GFP_KERNEL)?
I haven't checked.

+		spref = rpref;
+		slen = rlen;
+		rpref = opt->dccpop_val;
+		rlen = opt->dccpop_len;

This one is cosmetic, but some folks like these assignments aligned at
the =, like:

     spref = rpref;
     slen   = rlen;

+int dccp_feat_init(struct sock *sk)
+{
+	struct dccp_sock *dp;
+	int rc;
+	gfp_t gfp = GFP_KERNEL; /* XXX is this correct ? */

well, you could have dccp_feat_init() receiving this gfp_t and look at
the callsites to
see wheter GFP_KERNEL or GFP_ATOMIC should be used, if its just of one type... I
haven't looked at where dccp_feat_init commences, but I guess that we can have
this as just GFP_KERNEL.

+	/* confirm any options [NN opts] */
+	list_for_each_entry_safe(opt, next, &dp->dccps_options.dccpo_conf,
+				 dccpop_list) {
+		dccp_insert_feat_opt(skb, opt->dccpop_type,
+				     opt->dccpop_feat, opt->dccpop_val,
+				     opt->dccpop_len);
+		
+		/* fear empty confirms */
+		if (opt->dccpop_val)
+			kfree(opt->dccpop_val);
+		kfree(opt);

Humm, kfree without removing opt from dccps_options.dccpo_conf?

+	}
+	INIT_LIST_HEAD(&dp->dccps_options.dccpo_conf);

Ah, ok, saving some cycles, should be safe :-)


+	list_for_each_entry(opt, &dp->dccps_options.dccpo_pending, dccpop_list){

spaces between ) and { please


       Please look at this patch again taking those aspects into
consideration and I'll be
glad to merge it so that we can get back at testing all these new features.

        Ah, thanks a lot for following the general naming of structs,
functions, etc, its very
nice to have consistent coding guidelines!

- Arnaldo
