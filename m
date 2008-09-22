From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 22 Sep 2008 17:00:13 +0000
Subject: Re: [PATCH 2/5] dccp: Implement lookup table for
Message-Id: <20080922170013.GF16625@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1222068117-13401-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1222068117-13401-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Mon, Sep 22, 2008 at 05:45:54PM +0200, Gerrit Renker escreveu:
> | > --- a/include/linux/dccp.h
> | > +++ b/include/linux/dccp.h
> | >  
> | > +
> | > +static int dccp_feat_default_value(u8 feat_num)
> | > +{
> | > +	int idx = dccp_feat_index(feat_num);
> | > +
> | > +	return idx < 0 ? : dccp_feat_table[idx].default_value;
> | > +}
> | 
> | [acme@doppio ~]$ cat dd.c
> | #include <stdio.h>
> | 
> | int main(void)
> | {
> | 	int idx = -2;
> | 
> | 	printf("%d\n", idx < 0 ? : 10);
> | 	printf("%d\n", idx < 0 ? idx : 10);
> | 	return 0;
> | }
> | [acme@doppio ~]$ ./dd
> | 1
> | -2
> | [acme@doppio ~]$
> | 
> | Which one do you want? The boolean result as the value to be returned or
> | the index if it is < 0?
> | 
> It is the first value. The test is only there to avoid accessing the
> array with an invalid index, which would happen if an unknown `feat_num'
> is passed - as for unknown features there is no default value.

The above explanation would be good to have as a comment, as it was not
so obvious from a first sight. I think that even having it explicit
would be clearer:

return idx < 0 ? 1 : dccp_feat_table[idx].default_value;

But then, if an unknown feat num is passed shouldn't the code bailout in
some other fashion than returning the result of a boolean expression and
not accessing the defaults table?

- Arnaldo
