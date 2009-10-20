From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Tue, 20 Oct 2009 13:51:36 +0000
Subject: Re: [PATCHv2 1/4] First Patch on TFRC-SP. Copy base files from TFRC
Message-Id: <cb00fa210910200651r6cc0a7adq971fbc2c21c7fedf@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B677.4000308@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B677.4000308@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Mon, Oct 19, 2009 at 02:21, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> | First Patch on TFRC-SP.
> Please find attached one edit that I made.
>
> I added unwinding the initialisation of tfrc_lib in the case where the
> initialisation of tfrc_sp_lib fails. =A0Unwinding is now done in the reve=
rse
> order of the steps done during initialisation.
>

Agree.



--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
