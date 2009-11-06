From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Fri, 06 Nov 2009 00:16:21 +0000
Subject: Re: dccp-test-tree [PATCH 1/1]: Count lost data packets in a burst
Message-Id: <cb00fa210911051616o186b30cau527f7d92e4ad121f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Mon, Oct 19, 2009 at 02:16, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> dccp: Generalise data-loss condition
>
> This patch is thanks to Ivo Calado who had integrated this function into =
one
> of the TFRC-SP patches.
>
> It generalises the task of determining data loss from RFC 43430, 7.7.1.
>
> Let S_A, S_B be sequence numbers such that S_B is "after" S_A, and let
> N_B be the NDP count of packet S_B. Then, using module-2^48 arithmetic,
> =A0D =3D S_B - S_A - 1 =A0is an upper bound of the number of lost data pa=
ckets,
> =A0D - N_B =A0 =A0 =A0 =A0 =A0 =A0is an approximation of the number of lo=
st data packets
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(there are cases where this is not=
 exact).
>
> The patch implements this as
> =A0dccp_loss_count(S_A, S_B, N_B) :=3D max(S_B - S_A - 1 - N_B, 0)
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
> =A0net/dccp/dccp.h | =A0 21 +++++++++++++++------
> =A01 file changed, 15 insertions(+), 6 deletions(-)
>
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -153,18 +153,27 @@ static inline u64 max48(const u64 seq1,
> =A0}
>
> =A0/**
> - * dccp_loss_free =A0- =A0Evaluates condition for data loss from RFC 434=
0, 7.7.1
> - * @s1: =A0 =A0 =A0 =A0 start sequence number
> - * @s2: =A0end sequence number
> + * dccp_loss_count - Approximate the number of lost data packets in a bu=
rst loss
> + * @s1: =A0last known sequence number before the loss ('hole')
> + * @s2: =A0first sequence number seen after the 'hole'
> =A0* @ndp: NDP count on packet with sequence number @s2
> - * Returns true if the sequence range s1...s2 has no data loss.
> =A0*/
> -static inline bool dccp_loss_free(const u64 s1, const u64 s2, const u64 =
ndp)
> +static inline u64 dccp_loss_count(const u64 s1, const u64 s2, const u64 =
ndp)
> =A0{
> =A0 =A0 =A0 =A0s64 delta =3D dccp_delta_seqno(s1, s2);
>
> =A0 =A0 =A0 =A0WARN_ON(delta < 0);
> - =A0 =A0 =A0 return (u64)delta <=3D ndp + 1;
> + =A0 =A0 =A0 delta -=3D ndp + 1;
> +
> + =A0 =A0 =A0 return delta > 0 ? delta : 0;
> +}
> +
> +/**
> + * dccp_loss_free - Evaluate condition for data loss from RFC 4340, 7.7.1
> + */
> +static inline bool dccp_loss_free(const u64 s1, const u64 s2, const u64 =
ndp)
> +{
> + =A0 =A0 =A0 return dccp_loss_count(s1, s2, ndp) =3D 0;
> =A0}
>
> =A0enum {
>


Agree

--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Putt's Law:
       Technology is dominated by two types of people:
               Those who understand what they do not manage.
               Those who manage what they do not understand.
