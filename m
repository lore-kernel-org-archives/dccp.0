From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 14 Oct 2007 00:15:45 +0000
Subject: Re: [PATCH 2/5]: More informative registration
Message-Id: <5640c7e00710131715o9a74eaev4dbe88b9faac8aab@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710121051.51875@strip-the-willow>
In-Reply-To: <200710121051.51875@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID]: More informative registration
>
> The patch makes the registration messages of CCID 2/3 a bit more
> informative: instead of repeating the CCID number as currently done,
>
>         "CCID: Registered CCID 2 (ccid2)"  or
>         "CCID: Registered CCID 3 (ccid3)",
>
> the descriptive names of the CCID's (from RFCs) are now used:
>
>         "CCID: Registered CCID 2 (TCP-like)" and
>         "CCID: Registered CCID 3 (TCP-Friendly Rate Control)".
>
> To allow spaces in the name, the slab name string has been changed to
> refer to the numeric CCID identifier, using the same format as before.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
