RSpec.describe ActiverecordCursorPagination::OrderBase do
  subject do
    ActiverecordCursorPagination::OrderBase.new 'posts', 'created_at', 12
  end

  let (:subject_without_table) { ActiverecordCursorPagination::OrderBase.new nil, 'created_at', 123 }
  let (:subject_with_nonexistant_table) { ActiverecordCursorPagination::OrderBase.new 'comments', 'created_at', 1234 }
  let (:subject_with_invalid_table) { ActiverecordCursorPagination::OrderBase.new '(CASE WHEN id % 2 THEN 1 ELSE 0)', 'created_at', 1234 }
  let (:subject_with_invalid_name) { ActiverecordCursorPagination::OrderBase.new nil, '(CASE WHEN id % 2 THEN 1 ELSE 0)', 12345 }

  describe '.direction' do
    it 'raises NotImplemented' do
      expect { subject.direction }.to raise_error(NotImplementedError)
    end
  end

  describe '.base_id?' do
    it 'defaults to false' do
      expect(subject.base_id?).to be false
    end

    context 'when base_id is true' do
      subject do
        order = ActiverecordCursorPagination::OrderBase.new 'posts', 'created_at', 1
        order.base_id = true
        order
      end

      it 'returns true' do
        expect(subject.base_id?).to be true
      end
    end

    context 'when base_id is false' do
      subject do
        order = ActiverecordCursorPagination::OrderBase.new 'posts', 'created_at', 1
        order.base_id = false
        order
      end

      it 'returns false' do
        expect(subject.base_id?).to be false
      end
    end
  end

  describe '.table?' do
    context 'with table passed' do
      it 'returns true' do
        expect(subject.table?).to be true
      end
    end

    context 'with table passed as nil' do
      it 'returns false' do
        expect(subject_without_table.table?).to be false
      end
    end

    context 'with invalid table name' do
      it 'returns true' do
        expect(subject_with_invalid_table.table?).to be true
      end
    end
  end

  describe '.table_exists?' do
    context 'with table passed' do
      it 'returns true for existing table' do
        expect(subject.table_exists?).to be true
      end

      it 'returns false for nonexistent table' do
        expect(subject_with_nonexistant_table.table_exists?).to be false
      end
    end

    context 'with table passed as nil' do
      it 'returns false' do
        expect(subject_without_table.table_exists?).to be false
      end
    end

    context 'with invalid table name' do
      it 'returns false' do
        expect(subject_with_invalid_table.table_exists?).to be false
      end
    end
  end

  describe '.valid_table_name?' do
    context 'with valid table name passed' do
      it 'returns true' do
        expect(subject.valid_table_name?).to be true
      end
    end

    context 'with invalid table name passed' do
      it 'returns false' do
        expect(subject_with_invalid_table.valid_table_name?).to be false
      end
    end

    context 'with nil table name passed' do
      it 'returns false' do
        expect(subject_without_table.valid_table_name?).to be false
      end
    end
  end

  describe '.valid_name?' do
    context 'with valid name' do
      it 'returns true' do
        expect(subject.valid_name?).to be true
      end
    end

    context 'with invalid name' do
      it 'returns false' do
        expect(subject_with_invalid_name.valid_name?).to be false
      end
    end
  end

  describe '.statement_key' do
    it 'returns order_field12' do
      expect(subject.statement_key).to be :order_field12
    end

    it 'returns order_field123' do
      expect(subject_without_table.statement_key).to be :order_field123
    end

    it 'returns order_field1234' do
      expect(subject_with_invalid_table.statement_key).to be :order_field1234
    end

    it 'returns order_field12345' do
      expect(subject_with_invalid_name.statement_key).to be :order_field12345
    end
  end

  describe '.full_name' do
    context 'with table' do
      it 'returns table.column' do
        expect(subject.full_name).to eq 'posts.created_at'
      end
    end

    context 'without table' do
      it 'returns column' do
        expect(subject_without_table.full_name).to eq 'created_at'
      end
    end
  end

  describe '.quoted_full_name' do
    context 'with table' do
      it 'returns "table"."column"' do
        expect(subject.quote_full_name).to eq '"posts"."created_at"'
      end
    end

    context 'without table' do
      it 'returns "column"' do
        expect(subject_without_table.quote_full_name).to eq '"created_at"'
      end
    end
  end

  describe '.quoted_table' do
    context 'with table' do
      it 'returns "table"' do
        expect(subject.quote_table).to eq '"posts"'
      end
    end

    context 'without table' do
      it 'returns nil' do
        expect(subject_without_table.quote_table).to be_nil
      end
    end
  end

  describe '.quoted_name' do
    it 'returns "column"' do
      expect(subject.quote_name).to eq '"created_at"'
    end
  end

  describe '.reverse' do
    it 'raises NotImplemented' do
      expect {subject.reverse}.to raise_error(NotImplementedError)
    end
  end

  describe '.equals_sql' do
    it 'returns "table"."column" = :statement_key' do
      expect(subject.equals_sql).to eq '"posts"."created_at" = :order_field12'
    end
  end

  describe '.than_op' do
    it 'raises NotImplemented' do
      expect {subject.than_op}.to raise_error(NotImplementedError)
    end
  end

  describe '.than_sql' do
    it 'raises NotImplemented' do
      expect {subject.than_sql}.to raise_error(NotImplementedError)
    end
  end

  describe '.than_or_equal_op' do
    it 'raises NotImplemented' do
      expect {subject.than_or_equal_op}.to raise_error(NotImplementedError)
    end
  end

  describe '.than_or_equal_sql' do
    it 'raises NotImplementedError' do
      expect {subject.than_or_equal_sql}.to raise_error(NotImplementedError)
    end
  end

  describe '.order_sql' do
    it 'raises NotImplementedError' do
      expect {subject.order_sql}.to raise_error(NotImplementedError)
    end
  end

  describe '#order_factory' do
    it 'returns AscendingOrder on nil' do
      expect(ActiverecordCursorPagination::OrderBase.order_factory nil).to be ActiverecordCursorPagination::AscendingOrder
    end

    it 'returns AscendingOrder on :asc' do
      expect(ActiverecordCursorPagination::OrderBase.order_factory :asc).to be ActiverecordCursorPagination::AscendingOrder
    end

    it 'returns AscendingOrder on "asc"' do
      expect(ActiverecordCursorPagination::OrderBase.order_factory "asc").to be ActiverecordCursorPagination::AscendingOrder
    end

    it 'returns AscendingOrder on "ASC"' do
      expect(ActiverecordCursorPagination::OrderBase.order_factory "ASC").to be ActiverecordCursorPagination::AscendingOrder
    end

    it 'returns DescendingOrder on :desc' do
      expect(ActiverecordCursorPagination::OrderBase.order_factory :desc).to be ActiverecordCursorPagination::DescendingOrder
    end

    it 'returns DescendingOrder on "desc"' do
      expect(ActiverecordCursorPagination::OrderBase.order_factory "desc").to be ActiverecordCursorPagination::DescendingOrder
    end

    it 'returns DescendingOrder on "DESC"' do
      expect(ActiverecordCursorPagination::OrderBase.order_factory "DESC").to be ActiverecordCursorPagination::DescendingOrder
    end
  end

  describe '#parse_string' do
    subject { ActiverecordCursorPagination::OrderBase.parse_string 'test', 123456 }

    it 'passes the correct index' do
      expect(subject.index).to be 123456
    end

    context 'when Arel::Nodes::SqlLiteral' do
      context 'without order definition' do
        context 'when table.column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('posts.created_at'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table".column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('"posts".created_at'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when table."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('posts."created_at"'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table"."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('"posts"."created_at"'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when column only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('created_at'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "column" only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('"created_at"'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T.created_at' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('T.created_at'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T."created_at"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('T."created_at"'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when complex query' do
          context 'when alias T.created_at' do
            subject do
              ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new("(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)"),

                                                                   1
            end

            it 'is a AscendingOrder' do
              expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
            end

            it 'table is nil' do
              expect(subject.table).to be_nil
            end

            it 'column is "(CASE WHEN created_at < NOW() - INTERVAL "1 day" THEN 1 ELSE 0 END)"' do
              expect(subject.name).to eq "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)"
            end
          end
        end
      end

      context 'when ascending order' do
        context 'when table.column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('posts.created_at asc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table".column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('"posts".created_at asc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when table."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('posts."created_at" asc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table"."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('"posts"."created_at" asc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when column only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('created_at asc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "column" only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('"created_at" asc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T.created_at' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('T.created_at asc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T."created_at"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('T."created_at" asc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when complex query' do
          context 'when alias T.created_at' do
            subject do
              ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new("(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END) asc"),

                                                                   1
            end

            it 'is a AscendingOrder' do
              expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
            end

            it 'table is nil' do
              expect(subject.table).to be_nil
            end

            it 'column is "(CASE WHEN created_at < NOW() - INTERVAL "1 day" THEN 1 ELSE 0 END)"' do
              expect(subject.name).to eq "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)"
            end
          end
        end
      end

      context 'when descending order' do
        context 'when table.column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('posts.created_at desc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table".column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('"posts".created_at desc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when table."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('posts."created_at" desc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table"."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('"posts"."created_at" desc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when column only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('created_at desc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "column" only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('"created_at" desc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T.created_at' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('T.created_at desc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T."created_at"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new('T."created_at" desc'),
                                                                 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when complex query' do
          context 'when alias T.created_at' do
            subject do
              ActiverecordCursorPagination::OrderBase.parse_string Arel::Nodes::SqlLiteral.new("(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END) desc"),

                                                                   1
            end

            it 'is a AscendingOrder' do
              expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
            end

            it 'table is nil' do
              expect(subject.table).to be_nil
            end

            it 'column is "(CASE WHEN created_at < NOW() - INTERVAL "1 day" THEN 1 ELSE 0 END)"' do
              expect(subject.name).to eq "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)"
            end
          end
        end
      end
    end

    context 'when a String' do
      context 'without order definition' do
        context 'when table.column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'posts.created_at', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table".column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string '"posts".created_at', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when table."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'posts."created_at"', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table"."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string '"posts"."created_at"', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when column only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'created_at', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "column" only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string '"created_at"', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T.created_at' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'T.created_at', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T."created_at"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'T."created_at"', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when complex query' do
          context 'when alias T.created_at' do
            subject do
              ActiverecordCursorPagination::OrderBase.parse_string "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)", 1
            end

            it 'is a AscendingOrder' do
              expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
            end

            it 'table is nil' do
              expect(subject.table).to be_nil
            end

            it 'column is "(CASE WHEN created_at < NOW() - INTERVAL "1 day" THEN 1 ELSE 0 END)"' do
              expect(subject.name).to eq "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)"
            end
          end
        end
      end

      context 'when ascending order' do
        context 'when table.column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'posts.created_at asc', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table".column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string '"posts".created_at asc', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when table."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'posts."created_at" asc', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table"."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string '"posts"."created_at" asc', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when column only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'created_at asc', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "column" only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string '"created_at" asc', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T.created_at' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'T.created_at asc', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T."created_at"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'T."created_at" asc', 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when complex query' do
          context 'when alias T.created_at' do
            subject do
              ActiverecordCursorPagination::OrderBase.parse_string "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END) asc", 1
            end

            it 'is a AscendingOrder' do
              expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
            end

            it 'table is nil' do
              expect(subject.table).to be_nil
            end

            it 'column is "(CASE WHEN created_at < NOW() - INTERVAL "1 day" THEN 1 ELSE 0 END)"' do
              expect(subject.name).to eq "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)"
            end
          end
        end
      end

      context 'when descending order' do
        context 'when table.column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'posts.created_at desc', 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table".column' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string '"posts".created_at desc', 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when table."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'posts."created_at" desc', 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table"."column"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string '"posts"."created_at" desc', 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when column only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'created_at desc', 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "column" only' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string '"created_at" desc', 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T.created_at' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'T.created_at desc', 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T."created_at"' do
          subject do
            ActiverecordCursorPagination::OrderBase.parse_string 'T."created_at" desc', 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when complex query' do
          context 'when alias T.created_at' do
            subject do
              ActiverecordCursorPagination::OrderBase.parse_string "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END) desc", 1
            end

            it 'is a DescendingOrder' do
              expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
            end

            it 'table is nil' do
              expect(subject.table).to be_nil
            end

            it 'column is "(CASE WHEN created_at < NOW() - INTERVAL "1 day" THEN 1 ELSE 0 END)"' do
              expect(subject.name).to eq "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)"
            end
          end
        end
      end
    end
  end

  describe '#parse_order_node' do
    subject do
      node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new('test')
      ActiverecordCursorPagination::OrderBase.parse_order_node node, 123456
    end

    it 'passes the correct index' do
      expect(subject.index).to be 123456
    end

    context 'when Arel::Nodes::Ascending' do
      context 'when expr is a SqlLiteral' do
        context 'when table.column' do
          subject do
            node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new('posts.created_at')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table".column' do
          subject do
            node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new('"posts".created_at')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when table."column"' do
          subject do
            node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new('posts."created_at"')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table"."column"' do
          subject do
            node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new('"posts"."created_at"')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when column only' do
          subject do
            node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new('created_at')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "column" only' do
          subject do
            node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new('"created_at"')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T.created_at' do
          subject do
            node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new('T.created_at')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T."created_at"' do
          subject do
            node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new('T."created_at"')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a AscendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when complex query' do
          context 'when alias T.created_at' do
            subject do
              node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new("(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)")
              ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
            end

            it 'is a AscendingOrder' do
              expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
            end

            it 'table is nil' do
              expect(subject.table).to be_nil
            end

            it 'column is "(CASE WHEN created_at < NOW() - INTERVAL "1 day" THEN 1 ELSE 0 END)"' do
              expect(subject.name).to eq "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)"
            end
          end
        end
      end

      context 'when expr is a table relation' do
        subject do
          table = Arel::Nodes::TableAlias.new nil, 'posts'
          column = Arel::Nodes::TableAlias.new table, 'created_at'
          node = Arel::Nodes::Ascending.new column
          ActiverecordCursorPagination::OrderBase.parse_order_node node, 1234
        end

        it 'is a AscendingOrder' do
          expect(subject).to be_a ActiverecordCursorPagination::AscendingOrder
        end

        it 'is for posts table' do
          expect(subject.table).to eq 'posts'
        end

        it 'is for created_at table' do
          expect(subject.name).to eq 'created_at'
        end
      end
    end

    context 'when Arel::Nodes::Descending' do
      context 'when expr is a SqlLiteral' do
        context 'when table.column' do
          subject do
            node = Arel::Nodes::Descending.new Arel::Nodes::SqlLiteral.new('posts.created_at')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table".column' do
          subject do
            node = Arel::Nodes::Descending.new Arel::Nodes::SqlLiteral.new('"posts".created_at')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when table."column"' do
          subject do
            node = Arel::Nodes::Descending.new Arel::Nodes::SqlLiteral.new('posts."created_at"')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "table"."column"' do
          subject do
            node = Arel::Nodes::Descending.new Arel::Nodes::SqlLiteral.new('"posts"."created_at"')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "posts"' do
            expect(subject.table).to eq "posts"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when column only' do
          subject do
            node = Arel::Nodes::Descending.new Arel::Nodes::SqlLiteral.new('created_at')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when "column" only' do
          subject do
            node = Arel::Nodes::Descending.new Arel::Nodes::SqlLiteral.new('"created_at"')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is nil' do
            expect(subject.table).to be_nil
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T.created_at' do
          subject do
            node = Arel::Nodes::Descending.new Arel::Nodes::SqlLiteral.new('T.created_at')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when alias T."created_at"' do
          subject do
            node = Arel::Nodes::Descending.new Arel::Nodes::SqlLiteral.new('T."created_at"')
            ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
          end

          it 'is a DescendingOrder' do
            expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
          end

          it 'table is "T"' do
            expect(subject.table).to eq "T"
          end

          it 'column is "created_at"' do
            expect(subject.name).to eq "created_at"
          end
        end

        context 'when complex query' do
          context 'when alias T.created_at' do
            subject do
              node = Arel::Nodes::Descending.new Arel::Nodes::SqlLiteral.new("(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)")
              ActiverecordCursorPagination::OrderBase.parse_order_node node, 1
            end

            it 'is a DescendingOrder' do
              expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
            end

            it 'table is nil' do
              expect(subject.table).to be_nil
            end

            it 'column is "(CASE WHEN created_at < NOW() - INTERVAL "1 day" THEN 1 ELSE 0 END)"' do
              expect(subject.name).to eq "(CASE WHEN created_at < NOW() - INTERVAL '1 day' THEN 1 ELSE 0 END)"
            end
          end
        end
      end

      context 'when expr is a table relation' do
        subject do
          table = Arel::Nodes::TableAlias.new nil, 'posts'
          column = Arel::Nodes::TableAlias.new table, 'created_at'
          node = Arel::Nodes::Descending.new column
          ActiverecordCursorPagination::OrderBase.parse_order_node node, 1234
        end

        it 'is a DescendingOrder' do
          expect(subject).to be_a ActiverecordCursorPagination::DescendingOrder
        end

        it 'is for posts table' do
          expect(subject.table).to eq 'posts'
        end

        it 'is for created_at table' do
          expect(subject.name).to eq 'created_at'
        end
      end
    end
  end

  describe '#parse' do
    subject do
      ActiverecordCursorPagination::OrderBase.parse 'test', 12345
    end

    it 'passes correct index' do
      expect(subject.index).to be 12345
    end

    context 'when passing a string' do
      it 'calls parse_string' do
        expect(ActiverecordCursorPagination::OrderBase).to receive(:parse_string)

        ActiverecordCursorPagination::OrderBase.parse 'posts.created_at desc', 12345
      end
    end

    context 'when passing a SqlLiteral' do
      it 'calls parse_string' do
        expect(ActiverecordCursorPagination::OrderBase).to receive(:parse_string)

        ActiverecordCursorPagination::OrderBase.parse Arel::Nodes::SqlLiteral.new('posts.created_at desc'), 12345
      end
    end

    context 'when passing a Arel::Nodes::Node' do
      it 'calls parse_node' do
        expect(ActiverecordCursorPagination::OrderBase).to receive(:parse_order_node)

        node = Arel::Nodes::Ascending.new Arel::Nodes::SqlLiteral.new('created_at')
        ActiverecordCursorPagination::OrderBase.parse node, 12345
      end
    end
  end
end