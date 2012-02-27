From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Date: Mon, 27 Feb 2012 08:48:43 +0000
Subject: Re: Bug on CCID 3 of DCCP
Message-Id: <CAG_KctoBk=E0y-7DHr6GkGt5ZUdmYaw88RJmzSmOcBtFat_TnQ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
In-Reply-To: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 27 February 2012 02:05, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> Hi Ian,
> | Would suggest that patch is worth pushing upstreams then as quickly as
> we can...
> |
> I went through the code again and found that X_calc = 0 does not cause
> harm, due
> to clamping to s/t_mbi. My suggestion is to remove this BUG_ON and to test
> instead
> if t_ipi = 0 (since this would allow flooding of network).
>
> Patch is in the next email, test tree has been updated, also CCID-4 has
> now
> the same change (removed X_calc BUG_ON, added t_ipi=0 BUG_ON).
>
> Gerrit

Even better strategy!
