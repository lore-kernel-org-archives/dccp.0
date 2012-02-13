From: Jordi Salvador <salvador@wingsformedia.com>
Date: Mon, 13 Feb 2012 12:19:47 +0000
Subject: Re: Bug on CCID 3 of DCCP
Message-Id: <CAN3PNWfsmSJK1vBJHnW1wi1JM1gxmcNFBrH3GL7Gc0fJVD1mFQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
In-Reply-To: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hello Gerrit:

We have been trying to reproduce the bug, unsuccessfully. But there
are several comments we would like to share with you.

* You mentioned that "most of the computation needs 64 bits to avoid
truncating the numbers", and "if it is a non-64 bit architecture, it
could be conversion issues". The fact is that we use a 32-bit
architecture (an x86 compatible one), so it could be our case. But we
don't know how we can be sure (or reasonably almost sure) that this is
the case.

* You also said that "in several years of testing this bug has not yet
been reported on the mailing list". We don't know whether this testing
has included 32-bit machines (if so, perhaps we should discard
conversion issues as the cause of the bug...).

* You also mentioned that there are two conditions which could trigger
X_calc =3D 0 when p > 0, the second of them is that "the value of tx_s
in bytes is less than the value of the RTT in seconds". Since we don't
send packets of 1 or 2 bytes, we think we can safely rule out this
condition.

Before applying patches to the kernel we currently use (or download a
new one), we would like to enable debugging (following the
instructions you provided in your last email) in the kernel we use to
try to find what causes the bug.

We would also like to show you the relevant (from the DCCP point of
view) part of the configuration file we use to compile the kernel we
use, in order to provide you more information that might be useful.

$ grep -n CONFIG_IP_DCCP config-2.6.35.14
829:CONFIG_IP_DCCP=3Dm
835:# CONFIG_IP_DCCP_CCID2_DEBUG is not set
836:CONFIG_IP_DCCP_CCID3=3Dy
837:CONFIG_IP_DCCP_CCID3_DEBUG=3Dy
838:CONFIG_IP_DCCP_CCID3_RTO=100
839:CONFIG_IP_DCCP_TFRC_LIB=3Dy
840:CONFIG_IP_DCCP_TFRC_DEBUG=3Dy
845:CONFIG_IP_DCCP_DEBUG=3Dy
$ grep -n CONFIG_IP_DCCP config-2.6.35.4
828:CONFIG_IP_DCCP=3Dm
834:# CONFIG_IP_DCCP_CCID2_DEBUG is not set
835:CONFIG_IP_DCCP_CCID3=3Dy
836:# CONFIG_IP_DCCP_CCID3_DEBUG is not set
837:CONFIG_IP_DCCP_CCID3_RTO=100
838:CONFIG_IP_DCCP_TFRC_LIB=3Dy
843:# CONFIG_IP_DCCP_DEBUG is not set

Thanks again your your help and advise.

On 7 February 2012 05:10, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I went through the test tree code again. It is possible that X_calc =3D 0=
 when p > 0,
> but it could mask another bug. There are two conditions which could trigg=
er this
>
> =A0a) tx_s =3D 0
> =A0 =A0Packets with skb->len =3D 0 can not be sent since ccid3_hc_tx_send=
_packet() returns
> =A0 =A0EBADMSG in this case. The only possibility for tx_s then to become=
 0 is if
> =A0 =A0* CONFIG_IP_DCCP_CCID3_MEASURE_S_AS_MPS has been chosen to measure=
 the packet size,
> =A0 =A0* dccp_sk(sk)->dccps_mss_cache is 0 for some strange reason.
> =A0 =A0This could be tested by adding
> =A0 =A0 =A0 WARN_ON(dccp_sk(sk)->dccps_mss_cache =3D 0);
> =A0 =A0just before the 'return' in ccid3_hc_tx_measure_packet_size(). It =
would be very
> =A0 =A0helpful to find out whether this is the trigger.
>
> =A0b) The value of tx_s in bytes is less than the value of the RTT in sec=
onds
> =A0 =A0This would cause scaled_div(tx_s, RTT) to return 0 and consequentl=
y set x_calc =3D 0.
> =A0 =A0Due to DCCP_SANE_RTT_MAX, this would occur for packet sizes of 1 o=
r 2 bytes.
>
> The first case is the one to avoid. Could you turn on debugging by
> =A0* activating
> =A0 CONFIG_IP_DCCP_CCID3_DEBUG=3Dy
> =A0 CONFIG_IP_DCCP_DEBUG=3Dy
> =A0* adding debug via
> =A0 echo Y > /sys/module/dccp/parameters/ccid3_debug
> =A0 echo Y > /sys/module/dccp/parameters/dccp_debug
> =A0* watching the /var/log/messages or /var/log/kern.log
>
> I have been using CONFIG_IP_DCCP_CCID3_MEASURE_S_AS_MPS for a long time a=
nd never experienced
> a 0 value, but it does not mean it can never happen.
>
> Before committing to a fix that removes the BUG_ON, it is better to find =
out where the problem
> is coming from. If (a) can be ruled out, I will check through again and s=
ee if it is safe to
> allow x_calc =3D 0 -- a quick look seems to imply that it would work.
>
> However, tx_s =3D 0 must be avoided at all cases, since it can cause divi=
sion-by-zero in
> ccid3_update_send_interval().
>
> Gerrit



--=20
Jordi Salvador
+34934980980
+34660842146
salvador@wingsformedia.com

Warning: This e-mail is privileged, confidential and contains private
information. Any reading, retention, distribution or copying of this
communication by any person other than its intended recipient is
prohibited.
