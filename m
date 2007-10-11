From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 11 Oct 2007 09:02:08 +0000
Subject: Re: [PATCH 7/14]: No more CCID control blocks in LISTEN state
Message-Id: <5640c7e00710110202i5bb63177i598ac4de76e4b515@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.43141@strip-the-willow>
In-Reply-To: <200710031502.43141@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/11/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Kernel 2.6.23 is out and I have updated this patch with a small change
> which concerns the initialisation of hcrx/hctx after testing for OPEN|LISTEN|PARTOPEN.
>
> Also updated the changelog for this patch. Ian - please check whether you are still ok
> with this patch.
>
> -------------------------------> Patch v2 <--------------------------------------------
> [CCID3]: No more CCID control blocks in LISTEN state
>
> The CCIDs are activated as last of the features, at the end of the handshake, were
> the LISTEN state of the master socket is inherited into the server state of the child
> socket. Thus, the only states visible to CCIDs now are OPEN/PARTOPEN, and the closing
> states.
> This allows to remove tests which were previously necessary to protect against referencing
> a socket in the listening state (in CCID3), but which now have become redundant.
>
> Thanks to Ian McDonald for discussion on this.
>
> As a further byproduct of enabling the CCIDs only after the connection has been fully
> established, several typecast-initialisations of ccid3_hc_{rx,tx}_sock can now be eliminated:
>  * the CCID is loaded, so it is not necessary to test if it is NULL,
>  * if it is possible to load a CCID and leave the private area NULL, then this is a bug, which
>    should crash loudly and earlier,
>  * the test for state=OPEN || state=PARTOPEN now reduces only to the closing phase (e.g. when
>    the node has received an unexpected Reset).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Yes - still OK with it.
