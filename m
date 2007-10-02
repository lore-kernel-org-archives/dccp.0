From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 02 Oct 2007 12:27:05 +0000
Subject: Re: [PATCH 5/11]: Update insertion routine for feature-negotiation options
Message-Id: <200710021327.05763@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.21775@strip-the-willow>
In-Reply-To: <200710011518.21775@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > @@ -124,4 +124,5 @@ extern void dccp_encode_value_var(const
|  > =A0extern u64 =A0dccp_decode_value_var(const u8 *bf, const u8 len);
|  >
|  > =A0extern int =A0dccp_insert_option_mandatory(struct sk_buff *skb);
|  > +extern int =A0dccp_insert_fn_opt(struct sk_buff *skb, u8, u8, u8 *, u=
8, bool);
| =20
|  declarations in kernel should always have parameter names.
I personally disagree since I would look at the function itself to tell me =
what it
does (the above had carefully been butchered to match the other constraint =
of 80 linechars).

But I have changed it to the following (I omit the entire patch, the whole =
lot will be put
in the test tree when the discussion phase is over); the inter-diff is:

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -124,5 +124,6 @@ extern void dccp_encode_value_var(const=20
 extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
=20
 extern int  dccp_insert_option_mandatory(struct sk_buff *skb);
-extern int  dccp_insert_fn_opt(struct sk_buff *skb, u8, u8, u8 *, u8, bool=
);
+extern int  dccp_insert_fn_opt(struct sk_buff *skb, u8 type, u8 feat,
+			       u8 *val, u8 len, bool repeat_first);
 #endif /* _DCCP_FEAT_H */



