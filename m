From: gerrit@erg.abdn.ac.uk
Date: Sat, 19 Sep 2009 06:16:10 +0000
Subject: Re: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Message-Id: <5146.72.11.80.242.1253340970.squirrel@72.11.80.242>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
In-Reply-To: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

>> Also separated the conditions
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((len <=3D 0) ||
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (!tfrc_lh_closed_check(cur,
>> cong_evt->tfrchrx_ccval))) {
>> back into
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (len <=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!tfrc_lh_closed_check(cur, cong_evt->=
tfrchrx_ccval))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>>
>
> Thanks!
Yes I know, the above change is reintroduced by patch 2/2. Only found
out after I had gone through this one.


>> The following function pokes a hole in thei so far "abstract" data type;
>> the convention has been to access the internals of the struct only via
>> get-functions:
>>
>> static inline struct tfrc_loss_interval
>> =A0 =A0 =A0 =A0*tfrc_lh_get_loss_interval(struct tfrc_loss_hist *lh, con=
st u8 i)
>> {
>> =A0 =A0 =A0 =A0BUG_ON(i >=3D lh->counter);
>> =A0 =A0 =A0 =A0return lh->ring[LIH_INDEX(lh->counter - i - 1)];
>> }
>>
>> (You use it in patch 3/5 to gain access to li_ccval and li_losses.
>> Better would be to have two separate accessor functions.)
>>
>
> Okay, I will fix this.
>
It would be great but is secondary at this stage. The primary objective
should be to get a common prototype out soon, and then verify that it is
correct. I expect several rewrites of other code to make this possible,
so the above detail can also be fixed once a prototype has been found to
work satisfactorily.

