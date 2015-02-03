#!perl -T

use Test::Most import => ['!pass'];
use Plack::Test;
use HTTP::Request::Common;
use feature qw(fc);

sub isfc   { is fc(shift),   fc(shift), shift; }
sub isntfc { isnt fc(shift), fc(shift), shift; }

{

    package Webservice;
    use Dancer2;
    use Dancer2::Plugin::Negotiate;

    set plugins => {
        Negotiate => {
            languages => [qw[ de en ]],
        },
    };

    get '/' => sub {
        template negotiate 'index';
    };

}

my $PT = Plack::Test->create( Webservice->to_app );

plan tests => 3;

subtest C => sub {
    plan tests => 2;
    my $R = $PT->request( GET('/') );
    ok $R->is_success;
    isfc $R->content => 'C';
};

subtest EN => sub {
    plan tests => 3;
    my $R = $PT->request( GET( '/', 'Accept-Language' => 'en' ) );
    ok $R->is_success;
    isfc $R->header( fc 'Content-Language' ) => 'en';
    isfc $R->content                         => 'EN';
};

subtest DE => sub {
    plan tests => 3;
    my $R = $PT->request( GET( '/', 'Accept-Language' => 'de' ) );
    ok $R->is_success;
    isfc $R->header( fc 'Content-Language' ) => 'de';
    isfc $R->content                         => 'DE';
};

done_testing;
