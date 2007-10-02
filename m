From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 02 Oct 2007 00:36:25 +0000
Subject: Re: [PATCH 10/11]: Process incoming Change requests
Message-Id: <5640c7e00710011736pe177dcdq1840b30f3476134d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710011518.33998@strip-the-willow>
In-Reply-To: <200710011518.33998@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Process incoming Change requests
>
> This adds/replaces code for processing incoming Change feature-negotiation options.
>
> The main difference is that mandatory FN options are now interpreted inside the function
> (there are too many individual cases to do this externally); the function returns an
> appropriate Reset code or 0, which is then used by dccp_parse_options.
>
> Old code, which is no longer used or referenced, has been removed.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
