From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 20 Jul 2007 20:38:23 +0000
Subject: Re: iperf
Message-Id: <5640c7e00707201338l11d812f9l9a935319e2fa596b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi there Gerrit,

I agree it's best to have one code base and yours looks great now.
There's no need for anyone to use mine now really.

A lot of it isn't actually mine and was originally contributed by
others - I just picked it up and ran with it.

The only comment on your version is that you remove WIN32 code, and
rename some existing options. I had a hope that the code could get
merged upstream but my emails to the iperf list haven't succeeded in
this (probably because the CAIDA project has no funding).

Ian

On 7/21/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Ian,
>
> I also cleaned up my patch set to
>  * completely remove UDP-Lite from all other patches
>  * shift UDP-Lite to the end (as fourth patch)
>  * I have shamelessly stolen your `continuous' patch and integrated as patch #3
>  * result (patches 1..3) compiles without error or problems on a brandnew
>    installation of linux (with unmodified kernel headers)
>  * I haven't had time to look through your code, but I think we should put
>    out one combined client for testing purposes.
>
> I am not fussy who's it is we are using - the code is after all yours. I just
> polished it a bit up and made sure that the -b switch also works for DCCP.
>
> And I have found it quite a useful switch for testing, indeed.
>
> Results are on http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/patches/
>        (src:   http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/zip/ )
> Gerrit
>
> Quoting Ian McDonald:
> |  OK. I've hacked my iperf version around a bit to get closer to Gerrit's.
> |
> |  What I've done:
> |  - ported more of his code over
> |  -- renaming/shifting code
> |  -- fix service code handling to allow network byte order and correct name
> |  -- merged using -b option for DCCP (NB gives an error at end but seems
> |  to be working OK)
> |
> |  Our code still differs a bit e.g. I don't support UDP Lite yet.
> |
> |  So if you want unlimited run time and -b together then you want my
> |  tree, otherwise Gerrit's is probably better. I'm sure Gerrit can port
> |  my unlimited run time easily to his tree if he wants.
> |
> |  My patches are at:
> |  http://wand.net.nz/~iam4/iperf/
> |
> |  Ian
>


-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
