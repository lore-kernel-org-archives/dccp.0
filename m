From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Date: Sat, 16 Jul 2011 12:38:49 +0000
Subject: Re: dccp test-tree [RFC] [PATCH 0/7] dccp: dynamic feature
Message-Id: <CAG_KctqeqoaqRbFd_qpk-eqRjnEz+N_CyKtFQ+YFeyvUPdUmiw@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1310650955-5159-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1310650955-5159-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

I'm still OK with the patches that are acked by me. My email address
has changed though - ian.mcdonald@jandi.co.uk

On 14 July 2011 14:42, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> DCCP dynamic feature negotiation and Ack Ratio / Sequence Window update p=
atch set
>
> This submission is just for RFC (request for comments/confirmation).
>
> Patches #1, #2, #4 still need::
> =A0* Signed-off-bys from Samuel (please confirm),
> =A0 since he significantly contributed to the improvement of this set;
> =A0* Ian - I have kept your old Acked-by's despite the updates of the
> =A0 patches, please can you check if you are still ok with them.
>
> Changes have been mostly edits to resolve patch dependencies, and to comp=
ile
> independently. For reference I have added the commit messages from previo=
us
> iterations (these will be removed in the final version).
>
> Please review.
>
> I) The first part concerns negotiating features in established state:
> ---------------------------------------------------------------------
> =A0Patch #1: part 1/2 of negotiating feature changes in established state.
> =A0 =A0 =A0 =A0 =A0 =A0=3D> I would like to add Samuel's Signed-off-by he=
re.
> =A0Patch #2: part 2/2 of that set.
> =A0 =A0 =A0 =A0 =A0 =A0=3D> I would like to add Samuel's Signed-off-by he=
re.
> =A0Patch #3: send Confirm options only once.
>
>
> II) The second part uses these changes to improve CCID-2:
> ---------------------------------------------------------
> =A0Patch #4: adds the hooks to update Ack Ratio dynamically, but keeps it
> =A0 =A0 =A0 =A0 =A0 =A0disabled. Merged with Samuel's patch (=3D> Signed-=
off-by please),
> =A0 =A0 =A0 =A0 =A0 =A0I just updated the FIXME.
> =A0Patch #5: prevents CCID-2 cwnd > sequence window.
> =A0Patch #6: increment CCID-2 cwnd correctly.
> =A0Patch #7: check ack ratio when reducing cwnd
>
> ---
> =A0ccids/ccid2.c | =A0 88 +++++++++++++++++++------
> =A0ccids/ccid2.h | =A0 =A06 +
> =A0dccp.h =A0 =A0 =A0 =A0| =A0 =A01
> =A0feat.c =A0 =A0 =A0 =A0| =A0203 +++++++++++++++++++++++++++++++++++++++=
+++++++++++++++++--
> =A0feat.h =A0 =A0 =A0 =A0| =A0 =A01
> =A0proto.c =A0 =A0 =A0 | =A0 =A01
> =A06 files changed, 274 insertions(+), 26 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
