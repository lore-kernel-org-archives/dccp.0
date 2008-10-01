From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 01 Oct 2008 22:20:23 +0000
Subject: Re: Protocol not attached
Message-Id: <5640c7e00810011520m2f4d484dr66f198056f72a439@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Oct 2, 2008 at 10:38 AM, Leandro Sales <leandroal@gmail.com> wrote:
>
> On Wed, Oct 1, 2008 at 4:43 PM, Leandro Sales <leandroal@gmail.com> wrote:
> > On Wed, Oct 1, 2008 at 4:37 PM, Arnaldo Carvalho de Melo
> > <acme@redhat.com> wrote:
> >> Em Thu, Oct 02, 2008 at 08:32:20AM +1300, Ian McDonald escreveu:
> >>> >
> >>> > Just completing the information. Using 2.6.26 on arm worked.
> >>> >
> >>> > Time to use git-bisect then I would guess...
> >>
> >> Yes, its possible that this problem is not DCCP specific, perhaps
> >> affecting SCTP too. I.e. both are loadable modules usually, while TCP is
> >> always builtin.
> >>
> >> - Arnaldo
> >>
> >
> > Thanks Arnaldo and Ian.
> >
> > Then, is it necessary to report this issue in the kernel dev maillist?
> >
> > Regards,
> > Leandro.
> >
>
> An additional information:
>   I didn't run exhaustive tests, but I created a simple SCTP
> application and it didn't work too using 2.6.27.r6. Both (DCCP and
> SCTP) applications worked using 2.6.26.
>
> Regards,
> Leandro.

Well now would be time to test with vanilla Linus tree/2.6.27rc8 and
then post to netdev as it has become a regression then... And there is
probably another 5 people in the world who use SCTP to add to the 5
who use DCCP ;-)

Ian
