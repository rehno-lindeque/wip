self: super:

{
  sqlcrush = self.callPackage

    ({ lib, pythonPackages, fetchFromGitHub }:

    pythonPackages.buildPythonApplication rec {
      name = "sqlcrush-${version}";
      version = "0.1.5";

      # setup(name='sqlcrush',
      #         version='0.1.5',
      #         description='console based database editor',
      #         url='http://github.com/coffeeandscripts/sqlcrush',
      #         author='coffeeandscripts',
      #         author_email='ersari94@gmail.com',
      #         license='GNU',
      #         scripts=['bin/sqlcrush',],
      #         packages=['sqlcrush',],
      #         install_requires=['sqlalchemy', 'pymysql', 'psycopg2',],
      #         include_package_data=True
      # )

      src = fetchFromGitHub {
        sha256 = "1d5qdzkw7a7wjn2s05rkfzc1mflxcdv6af2g4yhhl6ssl03gqs57";
        rev = "75d81abb8e574f50291b7fea5f0f4d4725b3f804";
        repo = "sqlcrush";
        owner = "coffeeandscripts";
      };

      buildInputs = with pythonPackages; [ ];
      # checkPhase = ''
      #   mkdir /tmp/homeless-shelter
      #   HOME=/tmp/homeless-shelter py.test tests -k 'not test_missing_rc_dir and not test_quoted_db_uri and not test_port_db_uri'
      # '';

      propagatedBuildInputs = with pythonPackages; [
        sqlalchemy pymysql psycopg2
      ];

      # postPatch = ''
      #   substituteInPlace setup.py --replace "==" ">="
      #   rm tests/test_rowlimit.py
      # '';

      meta = with lib; {
        description = "console based database editor";
        longDescription = ''
          Grid-based editor for manipulating database tables in the terminal.
          Supports SQLite3, PostgreSQL and MariaDB/MySQL.
        '';
        homepage = https://github.com/coffeeandscripts/sqlcrush;
        license = licenses.gpl3;
        maintainers = with maintainers; [ ];
      };
    }) {};
}


