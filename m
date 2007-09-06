From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 04:22:24 +0000
Subject: Re: [PATCH 2/10]: Make PARTOPEN an autonomous state
Message-Id: <5640c7e00709052122v1b3ac3fau4e48e419461c4d0d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Make PARTOPEN an autonomous state
>
> This decouples PARTOPEN from TCP-specific stream-states, as suggested by
> the FIXME-comment.
>
> The code has been checked with regard to dependency on PARTOPEN and FIN_WAIT1
> states (to which PARTOPEN previously was mapped): there is no difference, as
> PARTOPEN is always referred to directly (i.e. not via the mapping to TCP state).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
