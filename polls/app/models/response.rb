# == Schema Information
#
# Table name: responses
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  answer_choice_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Response < ActiveRecord::Base
  validates :user_id, presence: true
  validates :answer_choice_id, presence: true
  validate :respondent_has_not_already_answered_question
  validate :respondent_can_not_answer_own_question

  belongs_to :answer_choice,
    foreign_key: :answer_choice_id,
    primary_key: :id,
    class_name: "AnswerChoice"

  belongs_to :respondent,
    foreign_key: :user_id,
    primary_key: :id,
    class_name: "User"

  has_one :question,
    through: :answer_choice,
    source: :question

  def sibling_responses
    # if id
      question.responses.where(":id IS NULL OR responses.id != :id", id: id)
    # else
    #   question.responses
    # end
  end

  private
  def respondent_has_not_already_answered_question
    if sibling_responses.exists?(user_id)
      errors[:user_id] << "User has already answered question."
    end
  end

  def respondent_can_not_answer_own_question
    if answer_choice.question.poll.author_id == user_id
      errors[:user_id] << "Can't answer own question."
    end
  end
end
