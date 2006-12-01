From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 01 Dec 2006 13:29:43 +0000
Subject: Re: [PATCHv2] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <39e6f6c70612010529g4c8db13ft704afef79dd5d43d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612011314.26835@strip-the-willow>
In-Reply-To: <200612011314.26835@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/1/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Hi Arnaldo,
>
> many thanks for the detailed feedback - that has taught me some things I did not know.
>
> I will reshape the patch with regards to comments. While at it, would like
> to increase resolution up to units of 100ms, with a default value of 10
> corresponding to the TCP RTO value - as per earlier email by Mark Handley.
>
>
> |  - "r_sample=%uus\n", dccp_role(sk), sk,
> |  + "r_sample=%us\n", dccp_role(sk), sk,
> |
> |  wrong, as r_sample is in microseconds, it comes from a timeval_delta,
> |  that gets it from dccp_timestamp and the elapsed times, originally in
> |  tenths of microsoeconds but multiplied by 10 to get back to
> |  microseconds.
> Disagree with the above, since r_sample is not changed and t_elapsed is
> converted from units of 10*microseconds to microsecond by multiplication:
>
>         r_sample = timeval_delta(&now, &packet->dccphtx_tstamp);
>         t_elapsed = dp->dccps_options_received.dccpor_elapsed_time * 10;
>
> I will put that into a different patch, as I am just going over previous ones
> that I have sent and checking each one of them.

We're agreeing Gerrit... you jumped to conclusions too fast because
you didn't read what I said in the next paragraph, that I quote here:

------------------------
Clarification on this one, you had _fixed_ it in your previous patch,
then removed this bit :)
------------------------

I.e. originally the printk message was using the '%us' mask, that
would erroneously print the r_sample value as if it was in seconds,
then you correctly changed it to '%uus' in the first patch, then, on
the one you asked me to replace the first one, you removed this fix,
what I said was that I kept this fix, i.e. changing from '%us' to
'%uus', which is the right thing.

- Arnaldo
