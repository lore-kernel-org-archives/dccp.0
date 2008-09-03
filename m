From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Sep 2008 08:18:39 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080903081839.GA9001@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| Why don't you put together a tree with just the changes that have
| gone through review and for which you have processed the feedback?
| --
I have a tree for the comments addressed so far. Below is a summary of
the things that have been addressed, when and in which manner.

At the end of the email is an interdiff, relative to the one sent on
Saturday, to reflect the changes that have been newly made to the set.

Urls are
	git://eden-feed.erg.abdn.ac.uk/dccp_exp	[subtree `dccp']
	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dshor=
tlog;h=DCcp

I will respond to Wei's comments after work.

------------------------------------ S u m m a r y ------------------------=
---

v3 [PATCH 1/1] dccp: Process incoming Change feature-negotiation options
 * fixed concern expressed by Wei to use an empty Confirm instead of a Rese=
t in response to an invalid Change R
 * I am beginning to question whether this is really the right thing to do,=
 may retract this change since it
   requires the host to send an invalid packet type. Anyway it is in the di=
ff below and on
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dco=
mmitdiff;hc036a38adc389ea49f84dc12f07fbc27be218e5

[PATCH 03/37] dccp: List management for new feature negotiation
 * addressed feedback by Arnaldo, using list_for_each_entry now
 * this was already addressed in the inter-diff from Saturday
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dco=
mmitdiff;h=E6340a7529dd5828a43828f6eb69344eff605902

[PATCH 04/37] dccp: Per-socket initialisation of feature negotiation=20
 * not addressed the suggestion to use hlist instead of list_head
 * this may be a possible optimisation for later

[PATCH 06/37] dccp: Limit feature negotiation to connection setup phase
 * responded to comment suggesting to reset connection instead of ignoring =
anytime feature negotiation
 * to me it seems that the current policy of silently ignoring anytime nego=
tiation is sufficient

[PATCH 07/37] dccp: Registration routines for changing feature values=20
 * clarified that registration is based on the registered CCIDs
 * fixed problem identified by Wei: it is permissible to have Confirm lists=
 of partially unknown values,
   the only requirement is that the confirmed value is valid
 * the update actually affects=20
   http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dco=
mmitdiff;hM4a0a149a2bbdc4381dee02251e9acd6d4967a3=09


[PATCH 08/37] dccp: Query supported CCIDs
 * clarified how the registration of new CCIDs is done (http://www.mail-arc=
hive.com/dccp@vger.kernel.org/msg02613.html)
 * the main point is that for the moment new CCIDs will remain highly exper=
imental, as a new CCID first requires to
   get an RFC accepted and published by the IETF

[PATCH 09/37] dccp: Resolve dependencies of features on choice of CCID     =
                                                      =20
 * suggestion by Arnaldo to use struct ccid_operations for the dependencies
 * response in separate thread: this makes the code more complex and should=
 be deferred

[PATCH 12/37] dccp: Feature negotiation for minimum-checksum-coverage=20
 * fixed problem pointed out by Arnaldo: changing state only after doing th=
e validity checks
 * already addressed in Saturday's diff
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dco=
mmitdiff;h=952d0535860021c3d5b4b10ca41525c85b3adf69

[PATCH 14/37] dccp: Tidy up setsockopt calls
 * addressed Arnaldo's comment that the switch statement could be simplified
 * addressed Eugene's comment regarding the typecast of optlen
 * already in Saturday's diff
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dco=
mmitdiff;h=EE09a66c65c9eccc181be2aef6ea6af63063869b

[PATCH 15/37] dccp: Set per-connection CCIDs via socket options
 * addressed Arnaldo's comment regarding the maximum option length
 * further generalised it when discussing the maximum length of (Confirm) o=
ptions
 * in Saturday's diff and below
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dco=
mmitdiff;h=EEc7ba87785539c7840baadd0203c0a848fb70f2=20

[PATCH 16/37] dccp: API to query the current TX/RX CCID=20
 * addressed Arnaldo's comment to simplify ccid_get_current_id into separat=
e ccid_get_current_{rx,tx}_ccid
 * already in Saturday's diff
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dco=
mmitdiff;h=8107a65e721bd36d97fc702796fa490884215b36

[PATCH 19/37] dccp: Header option insertion routine for feature-negotiation
 * responded to Wei's concerns regarding that the length check may be inval=
id (it is not)
 * http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dco=
mmitdiff;h=E8fa8c43e8741aec75e6a646885d0ab1009776b4


=3D=3D> Here is the interdiff reflecting yesterday's changes, relative to S=
aturday <=3D=3D

		 4 files changed, 10 insertions(+), 12 deletions(-)

--- b/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1083,13 +1083,10 @@
=20
 	/*
 	 *	Negotiation of NN features: Change R is invalid, so there is no
-	 *	simultaneous negotiation; hence we do not consult the list.
+	 *	simultaneous negotiation; hence we do not look up in the list.
 	 */
 	if (type =3D FEAT_NN) {
-		if (local)
-			goto not_valid_or_not_known;
-
-		if (len > sizeof(fval.nn))
+		if (local || len > sizeof(fval.nn))
 			goto unknown_feature_or_value;
=20
 		/* 6.3.2: "The feature remote MUST accept any valid value..." */
@@ -1230,8 +1227,9 @@
 	/*
 	 * Parsing SP Confirms: the first element of @val is the preferred
 	 * SP value which the peer confirms, the remainder depends on @len.
+	 * Note that only the confirmed value need to be a valid SP value.
 	 */
-	if (!dccp_feat_sp_list_ok(feat, val, len))
+	if (!dccp_feat_is_valid_sp_val(feat, val))
 		goto confirmation_failed;
=20
 	if (len =3D 1) {		/* peer didn't supply a preference list */
--- b/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -170,6 +170,8 @@
 	DCCPO_MIN_TX_CCID_SPECIFIC =3D 192,	/* from receiver to sender */
 	DCCPO_MAX_TX_CCID_SPECIFIC =3D 255,
 };
+/* maximum size of a single TLV-encoded DCCP option (sans type/len bytes) =
*/
+#define DCCP_SINGLE_OPT_MAXLEN	253
=20
 /* DCCP CCIDS */
 enum {
@@ -228,10 +230,6 @@
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
=20
-/* maximum size of a single TLV-encoded option (sans type/len bytes) */
-#define DCCP_SINGLE_OPT_MAXLEN         253
-/* maximum number of CCID preferences that can be registered at one time */
-#define DCCP_CCID_LIST_MAX_LEN         (DCCP_SINGLE_OPT_MAXLEN - 2)
 /* maximum number of services provided on the same listening port */
 #define DCCP_SERVICE_LIST_MAX_LEN      32
=20
--- b/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -15,13 +15,15 @@
 #include "dccp.h"
=20
 /*
- * Known limits of feature values.
+ * Known limit values
  */
 /* Ack Ratio takes 2-byte integer values (11.3) */
 #define DCCPF_ACK_RATIO_MAX	0xFFFF
 /* Wmin2 and Wmax=3D2^46-1 from 7.5.2 */
 #define DCCPF_SEQ_WMIN		32
 #define DCCPF_SEQ_WMAX		0x3FFFFFFFFFFFull
+/* Maximum number of SP values that fit in a single (Confirm) option */
+#define DCCP_FEAT_MAX_SP_VALS	(DCCP_SINGLE_OPT_MAXLEN - 2)
=20
 enum dccp_feat_type {
 	FEAT_AT_RX   =3D 1,	/* located at RX side of half-connection  */
--- b/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -475,7 +475,7 @@
 	u8 *val;
 	int rc =3D 0;
=20
-	if (optlen < 1 || optlen > DCCP_CCID_LIST_MAX_LEN)
+	if (optlen < 1 || optlen > DCCP_FEAT_MAX_SP_VALS)
 		return -EINVAL;
=20
 	val =3D kmalloc(optlen, GFP_KERNEL);
