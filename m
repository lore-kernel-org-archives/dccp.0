From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Oct 2007 12:50:59 +0000
Subject: Re: [PATCH 9/14]: Phase out the use of boolean flag for Ack Vectors
Message-Id: <200710041350.59642@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.47513@strip-the-willow>
In-Reply-To: <200710031502.47513@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > --- a/include/linux/dccp.h
|  > +++ b/include/linux/dccp.h
|  > @@ -372,7 +372,6 @@ static inline unsigned int dccp_hdr_len(
|  > =A0#define DCCPF_INITIAL_SEQUENCE_WINDOW =A0 =A0 =A0 =A0 =A0100
|  > =A0#define DCCPF_INITIAL_ACK_RATIO =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A02
|  > =A0#define DCCPF_INITIAL_CCID =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
DCCPC_CCID2
|  > -#define DCCPF_INITIAL_SEND_ACK_VECTOR =A0 =A0 =A0 =A0 =A01
|  > =A0/* FIXME: for now we're default to 1 but it should really be 0 */
|  > =A0#define DCCPF_INITIAL_SEND_NDP_COUNT =A0 =A0 =A0 =A0 =A0 1
|  >
|  Not sure if the fixme applies to ack_vector or send_ndp_count so
|  unsure if that should be removed also.
Well spotted - the FIXME applies to NDP count, both lines are removed in

[PATCH 13/14]: Initialisation and type-checking of feature sysctls

which has the following hunk:
@@ -368,13 +368,6 @@ static inline unsigned int dccp_hdr_len(
 }
=20
=20
-/* initial values for each feature */
-#define DCCPF_INITIAL_SEQUENCE_WINDOW          100
-#define DCCPF_INITIAL_ACK_RATIO                        2
-#define DCCPF_INITIAL_CCID                     DCCPC_CCID2
-/* FIXME: for now we're default to 1 but it should really be 0 */
-#define DCCPF_INITIAL_SEND_NDP_COUNT           1
-

The hardcoded constants are replaced by looking up the default value for th=
e feature
in the feat.c-lookup table (which itself has the defaults from 6.4).=20

Changes from global settings can be enforced by setting socket options.
