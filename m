From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 28 Apr 2008 21:29:48 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: External interface changes
Message-Id: <200804282329.48669.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080424220704.0483DBC12@poczta.oswiecenia.net>
In-Reply-To: <20080424220704.0483DBC12@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 28 of April 2008, Gerrit Renker napisa=B3:
> | @@ -721,9 +721,7 @@ static int dccp_msghdr_parse(struct msghdr *msg,
> | __u32 **priority)
> |
> |  		switch (cmsg->cmsg_type) {
> |  		case DCCP_SCM_PRIORITY:
> | -			if (cmsg->cmsg_len !=3D CMSG_LEN(sizeof(__u32)))
> | -				return -EINVAL;
> | -			*priority =3D (__u32 *)CMSG_DATA(cmsg);
> | +			*cmsg_qpolicy =3D cmsg;
> |  			break;
> |  		default:
> |  			return -EINVAL;
>
> Here the cmsg is exported to any current qpolicy. The disadvantages
> are	that * there is no longer any length check, the functions using this
> interface have in the worst case no idea how much the user wanted to pass,
> so this is dangerous (compare also RFC 3542, 20.2);
The information about size can be retrieved in specific qpolicy. It is not =

CMSG_DATA(cmsg) that is passed to qpolicy but cmsg itself along with cmsg_l=
en=20
field.

>  * the separation-of-concerns becomes unclear: now part of the parsing is
> done in dccp_msg_hdr_parse() and another part in some of the
> qpolicy_xxx_push() routines, so one routine does part of the work of
> another;
That is a problem. So I think all the code should be moved to=20
qpolicy_prio_push().

>  * each qpolicy_xxx_push() routine needs to have a cmsghdr* argument even
> if it is not used.
>
Before the change I could say: why call dccp_msghdr_parse() if choosen poli=
cy=20
cannot make use of it's result.
No matter what we will always have either "unnecessary code", "unnecessary =

parameter" or something else that is "unnecessary" simply because simple=20
policy is, well... simple. But it has to be so to keep interfaces clean.

> It is however possible to reach the same goal with just a small
> modification: * so far only one SCM message (DCCP_SCM_PRIORITY) has been
> defined; * maintainers generally accepted the use of skb->priority while =
on
> layer 4; * hence for all sub-variants of a "prio" policy (strict/partial
> orderings), one can use DCCP_SCM_PRIORITY, in combination with
> skb->priority; * for different policies, define a different DCCP_SCM_xxx
> message and store the cmsg data in a different field (to be decided);
>  * this has the advantage that type/length checking is all in one place,
>    so that the qpolicy routines need to do qpolicy only.
>
I would use different DCCP_SCM_xxx for different parameters. So that one=20
qpolicy could use more than one DCCP_SCM_xxx. And parsing of specific=20
DCCP_SCM_xxx should IMHO happen in qpolicy_*_push().

> | --- a/net/dccp/qpolicy.c
> | +++ b/net/dccp/qpolicy.c
> | @@ -57,8 +58,13 @@ static struct sk_buff *qpolicy_prio_worst_skb(struct
> | sock *sk) return worst;
> |  }
> |
> | -static void qpolicy_prio_push(struct sock *sk, struct sk_buff *skb)
> | +static void qpolicy_prio_push(struct sock *sk, struct sk_buff *skb,
> | +				struct cmsghdr *cmsg)
> |  {
> | +	struct dccp_qpolicy_prio_info info;
> | +	memcpy(&info, CMSG_DATA(cmsg), min(cmsg->cmsg_len, sizeof(info)));
>
> That is the problem I see - `info' could end up with garbled data, if the
> user had accidentally passed `u32' instead of CMSG_LEN(sizeof priority).
>
Right, but this could easily be fixed by initializing info prior to memcpy.=
=20
Then only data provided by user would override defaults. But see below.

> The CMSG_LEN() ensures an additional check - that the user is in fact usi=
ng
> proper encapsulation via CMSG_xxx macros and not via
> msg_control/msg_controllen directly. The latter leads to hard-to-debug
> problems: in my case, I found this works - by accident - on 32-bit Intel,
> but will fail on 64-bit computers in compatibility mode.
>
Then min(cmsg->cmsg_len, sizeof(info)) could be changed to min(CMSG_LEN(cms=
g),=20
sizeof(info)), I see no problem with that.

That said I think that multiple DCCP_SCM_xxx per policy might be a better=20
approach.
--=20
Regards,
Tomasz Grobelny
