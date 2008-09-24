From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 24 Sep 2008 04:41:20 +0000
Subject: Re: [PATCH 2/5] dccp: Implement lookup table for
Message-Id: <20080924044120.GA4944@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1222068117-13401-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1222068117-13401-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| > | > --- a/include/linux/dccp.h
| > | > +++ b/include/linux/dccp.h
| > | > =20
| > | > +
| > | > +static int dccp_feat_default_value(u8 feat_num)
| > | > +{
| > | > +	int idx =3D dccp_feat_index(feat_num);
| > | > +
| > | > +	return idx < 0 ? : dccp_feat_table[idx].default_value;
| > | > +}
<snip>
| > |=20
| > It is the first value. The test is only there to avoid accessing the
| > array with an invalid index, which would happen if an unknown `feat_num'
| > is passed - as for unknown features there is no default value.
|=20
| The above explanation would be good to have as a comment, as it was not
| so obvious from a first sight. I think that even having it explicit
| would be clearer:
|=20
| return idx < 0 ? 1 : dccp_feat_table[idx].default_value;
|=20
| But then, if an unknown feat num is passed shouldn't the code bailout in
| some other fashion than returning the result of a boolean expression and
| not accessing the defaults table?
|=20
Yes thank you. It is necessary to check this, since only in the current
state of code the use of the function is consistent.  If the code gets
changed later on then there will be no warning.

I have worked on this function yesterday evening with regard to above
feedback. If you could either check again when the patch is submitted
later, or have a look at the online version in the test tree on
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcommi=
tdiff;h=B0708121bfeb309db88e1b3a97cf851069bcafe1

