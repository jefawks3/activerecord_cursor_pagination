RSpec.describe ActiverecordCursorPagination::SqlSigner do
  describe '.sign' do
    let :query do
      Post.where(published: true)
          .order(created_at: :desc)
    end

    it 'returns hash signature' do
      expect(subject.sign(query)).to eq('ly/bDcwQzU2t3J1BeOp3nXjq4Lk=')
    end
  end
end