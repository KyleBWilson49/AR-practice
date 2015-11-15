# == Schema Information
#
# Table name: questions
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  text       :string
#  created_at :datetime
#  updated_at :datetime
#

class Question < ActiveRecord::Base
  validates :text, presence: true, uniqueness: true
  validates :poll_id, presence: true

  has_many :answer_choices,
    foreign_key: :question_id,
    primary_key: :id,
    class_name: "AnswerChoice"

  belongs_to :poll,
    foreign_key: :poll_id,
    primary_key: :id,
    class_name: "Poll"

  has_many :responses,
    through: :answer_choices,
    source: :responses

  def results
    # N+1 way:
    # results = {}
    # self.answer_choices.each do |answer_choice|
    #   results[answer_choice.text] = answer_choice.responses.count
    # end
    # results

    # 2-queries; all responses transferred:
    # results = {}
    # self.answer_choices.includes(:responses).eanswer_choiceh do |answer_choice|
    #   results[answer_choice.text] = answer_choice.responses.length
    # end
    # results

    # 1-query way
    answer_choices = self.answer_choices
      .select("answer_choices.*, COUNT(responses.id) AS num_responses")
      .joins(<<-SQL).group("answer_choices.id")
  end
end
