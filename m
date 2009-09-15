From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 15 Sep 2009 00:41:13 +0000
Subject: Re: [PATCH 5/5] Updating documentation accordingly
Message-Id: <cb00fa210909141741r54cd541fi242b110a727fbfcc@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011946g744a4f5cvbe6a2e7642eaa8ff@mail.gmail.com>
In-Reply-To: <cb00fa210909011946g744a4f5cvbe6a2e7642eaa8ff@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Sun, Sep 13, 2009 at 15:50, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> | Updating documentation accordingly
>
> +/* As defined at section 8.6.1. of RFC 4342 */
> =A0#define TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH =A0 =A0 28
> +/* Specified on section 8.7. of CCID4 draft */
> =A0#define TFRC_DROP_OPT_MAX_LENGTH =A0 =A0 =A0 =A0 =A0 =A0 =A0 84
> Need to update the references to CCID4 draft with RFC 5622. See also 4/5.
>
> It would be more helpful to include the documentation for structs with
> the patches that use these structs.
>

Thanks, I'll fix this.

--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
