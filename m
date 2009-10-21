From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Wed, 21 Oct 2009 13:11:51 +0000
Subject: Re: ccid-4 [PATCH 1/1]: Add the new prefix scheme also to the CCID-4
Message-Id: <cb00fa210910210611y5c4f42bds35579734171f414a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20091019053231.GF3366@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20091019053231.GF3366@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Oct 19, 2009 at 02:32, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> Hi Ivo,
>
> please find below the patch to implement the prefix scheme introduced very recently,
> so that the CCID-4 tree also has the same naming conventions as used for CCID-3 and
> CCID-2. If you are ok with this, I would merge parts of it with the other patches
> (in particular the first CCID-4 patch, ccid4.patch), in order to make the patch size
> smaller.
>
Yes, I agree.




> >>>>>>>>>>>>>>>>>>>>>>> Patch v1 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>
>
> tfrc-sp: Implement prefix-scheme
>
> This ports the new prefix scheme introduced for the CCID-structs to TFRC-SP/CCID-4.
<snip>
> --



--
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
